//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 1/10/24.
//
import Foundation

final class ProfileImageService {
    
    // MARK: - Public Properties
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    private lazy var networkClient: NetworkRouting = NetworkClient()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    // Функция получает маленькую версию аватарки
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let request = createURLRequest(username: username) else {
            assertionFailure("Error: unable to create URL request")
            print("Error: unable to create URL request")
            return
        }
        
        networkClient.performRequestAndDecode(
            serviceType: .profile,
            request: request
        ) { [weak self] (result: Result<ProfileImageResult, Error>) in
            switch result {
            case .success(let response):
                let avatarURL = response.profileImage.small
                fulfillCompletionOnTheMainThread(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
            case .failure(let error):
                assertionFailure("Error: \(error)")
                print("Error: \(error)")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func createURLRequest(username: String) -> URLRequest? {
        guard let authToken = OAuth2TokenStorage.token else {
            assertionFailure("Error: authorization (bearer) token is not found")
            print("Error: authorization (bearer) token is not found")
            return nil
        }
        let url = Constants.defaultBaseURL.appendingPathComponent("users/\(username)")
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}
