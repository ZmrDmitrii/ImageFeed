//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/10/24.
//
import Foundation

final class ImagesListService {
    
    // MARK: - Public Properties
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
//    private lazy var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        DateFormatter().dateFormat = "yyy-MM-dd'T'HH:mm:ssXXX"
//        return formatter
//    }()
    
    // MARK: - Private Properties
    private(set) var photos: [PhotoViewModel] = []
    private lazy var networkClient: NetworkRouting = NetworkClient()
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        
        if task != nil { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = createURLRequest(nextPage: nextPage) else {
            assertionFailure("Error: unable to create URL request")
            print("Error: unable to create URL request")
            return
        }
        
        task = networkClient.performRequestAndDecode(
            request: request
        ) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let response):
                let newPhotos = response.compactMap { self?.createPhotoViewModel(from: $0) }
                self?.lastLoadedPage = nextPage
                self?.addPhoto(newPhotos)
                
//                for piece in response {
//                    guard let photo = self?.createPhotoViewModel(from: piece) else {
//                        assertionFailure("Error: unable to create Photo View Model")
//                        print("Error: unable to create Photo View Model")
//                        return
//                    }
//                    self?.addPhoto(photo)
//                }
                
            case .failure(let error):
                assertionFailure("Error: \(error)")
                print("Error: \(error)")
            }
            
            self?.task = nil
        }
    }
    
    // MARK: - Private Methods
    private func createURLRequest(nextPage: Int) -> URLRequest? {
        guard let authToken = OAuth2TokenStorage.token else {
            assertionFailure("Error: authorization (bearer) token is not found")
            print("Error: authorization (bearer) token is not found")
            return nil
        }
        
        let baseURL = Constants.defaultBaseURL.appendingPathComponent("photos")
        
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            assertionFailure("Error: failed to get defaultBaseURL")
            print("Error: failed to get defaultBaseURL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: String(10))
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Error: failed to get url")
            print("Error: failed to get url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func createPhotoViewModel(from response: PhotoResult) -> PhotoViewModel {
        
//        guard let createdAt: Date = dateFormatter.date(from: response.createdAt) else {
//            assertionFailure("Error: unable to convert string createdAt to Date format")
//            print("Error: unable to convert string createdAt to Date format")
//        }
    
        return PhotoViewModel(id: response.id,
                              createdAt: response.createdAt,
                              size: CGSize(width: response.width, height: response.height),
                              welcomeDescription: response.description,
                              thumbImageURL: response.urls.thumb,
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

