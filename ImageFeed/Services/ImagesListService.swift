//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/10/24.
//
import Foundation

final class ImagesListService {
    
    // MARK: - Errors
    
    enum DateConversionError: Error {
        case invalidDateFormat
    }
    
    // MARK: - Internal Properties
    
    var photos: [PhotoViewModel] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    // MARK: - Private Properties
    
    private lazy var networkClient: NetworkRouting = NetworkClient()
    private var lastLoadedPage: Int?
    private var fetchTask: URLSessionDataTask?
    private var changeLikeTask: URLSessionDataTask?
    private let dateFormatter = ISO8601DateFormatter()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Internal Methods
    
    func fetchPhotosNextPage() {
        guard fetchTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = createURLRequest(nextPage: nextPage) else {
            assertionFailure("Error: unable to create URL request")
            return
        }
        
        fetchTask = networkClient.performRequestAndDecode(
            request: request
        ) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let response):
                let newPhotos = response.compactMap {
                    do {
                        return try self?.createPhotoViewModel(from: $0)
                    } catch {
                        assertionFailure("Error: unable to convert Date")
                        return nil
                    }
                }
                self?.lastLoadedPage = nextPage
                self?.addPhoto(newPhotos)
            case .failure(let error):
                assertionFailure("Error: \(error)")
            }
            self?.fetchTask = nil
        }
    }
    
    func changeLike(photoID: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard changeLikeTask == nil else {
            UIBlockingProgressHUD.dismiss()
            return
        }
        
        guard let request = createLikeURLRequest(photoID: photoID, isLiked: isLiked) else {
            assertionFailure("Error: unable to create URL request")
            return
        }
        
        changeLikeTask = networkClient.performRequest(
            request: request
        ) { [weak self] result in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                assertionFailure("Error: \(error)")
            }
            self?.changeLikeTask = nil
        }
    }
    
    func cleanPhotos() {
        DispatchQueue.main.async {
            self.photos.removeAll()
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: ["photos": self.photos]
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func createURLRequest(nextPage: Int) -> URLRequest? {
        guard let authToken = OAuth2TokenStorage.token else {
            assertionFailure("Error: authorization (bearer) token is not found")
            return nil
        }
        
        guard let baseURL = Constants.defaultBaseURL?.appendingPathComponent("photos") else {
            assertionFailure("Error: unable to unwrap base URL")
            return nil
        }
        
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            assertionFailure("Error: failed to get defaultBaseURL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: String(10))
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Error: failed to get url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func createLikeURLRequest(photoID: String, isLiked: Bool) -> URLRequest? {
        guard let authToken = OAuth2TokenStorage.token else {
            assertionFailure("Error: authorization (bearer) token is not found")
            return nil
        }
        guard let url = Constants.defaultBaseURL?.appendingPathComponent("photos/\(photoID)/like") else {
            assertionFailure("Error: unable to unwrap base URL")
            return nil
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = isLiked ? "DELETE" : "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func createPhotoViewModel(from response: PhotoResult) throws -> PhotoViewModel {
        guard let date = dateFormatter.date(from: response.createdAt) else {
            throw DateConversionError.invalidDateFormat
        }
        
        return PhotoViewModel(id: response.id,
                              createdAt: date,
                              size: CGSize(width: response.width, height: response.height),
                              welcomeDescription: response.description,
                              thumbImageURL: response.urls.small,
                              largeImageURL: response.urls.full,
                              isLiked: response.isLiked)
    }
    
    private func addPhoto(_ arrayOfPhotos: [PhotoViewModel]) {
        DispatchQueue.main.async {
            self.photos.append(contentsOf: arrayOfPhotos)
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: ["photos": self.photos]
            )
        }
    }
}

