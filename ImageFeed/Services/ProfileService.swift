//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 26/9/24.
//
import Foundation

final class ProfileService {
    
    // MARK: - Internal Properties
    
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    
    private lazy var networkClient: NetworkRouting = NetworkClient()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Internal Methods
    
    func fetchProfile(completion: @escaping (Result<ProfileViewModel, Error>) -> Void) {
        
        guard let request = createURLRequest() else {
            assertionFailure("Error: unable to create URL request")
            return
        }
        
        _ = networkClient.performRequestAndDecode(
            request: request
        ) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let response):
                guard let profile = self?.createProfileViewModel(from: response) else {
                    assertionFailure("Error: unable to create Profile View Model")
                    return
                }
                completion(.success(profile))
            case .failure(let error):
                assertionFailure("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createURLRequest() -> URLRequest? {
        guard let authToken = OAuth2TokenStorage.token else {
            assertionFailure("Error: authorization (bearer) token is not found")
            return nil
        }
        guard let url = Constants.defaultBaseURL?.appendingPathComponent("me") else {
            assertionFailure("Error: unable to unwrap base URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func createProfileViewModel(from response: ProfileResult) -> ProfileViewModel {
        return ProfileViewModel(username: response.username,
                                name: response.firstName + " " + (response.lastName ?? ""),
                                loginName: "@" + response.username,
                                bio: response.bio)
    }
}
