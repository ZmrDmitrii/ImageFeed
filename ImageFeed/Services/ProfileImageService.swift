//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 1/10/24.
//
import Foundation

final class ProfileImageService {
    
    // MARK: - Internal Properties
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    
    private lazy var networkClient: NetworkRouting = NetworkClient()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Internal Methods
    
    // Функция получает маленькую версию аватарки
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = createURLRequest(username: username) else {
            assertionFailure("Error: unable to create URL request")
            return
        }
        
        _ = networkClient.performRequestAndDecode(
            request: request
        ) { [weak self] (result: Result<ProfileImageResult, Error>) in
            switch result {
            case .success(let response):
                let avatarURL = response.profileImage.small
                completion(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
            case .failure(let error):
                assertionFailure("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createURLRequest(username: String) -> URLRequest? {
        guard let authToken = OAuth2TokenStorage.token else {
            assertionFailure("Error: authorization (bearer) token is not found")
            return nil
        }
        guard let url = Constants.defaultBaseURL?.appendingPathComponent("users/\(username)") else {
            assertionFailure("Error: unable to unwrap base URL")
            return nil
        }
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
}
