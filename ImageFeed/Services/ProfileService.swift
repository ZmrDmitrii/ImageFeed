//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 26/9/24.
//
import Foundation

final class ProfileService {
    
    // MARK: - Public Properties
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    private lazy var networkClient: NetworkRouting = NetworkClient()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfile(completion: @escaping (Result<ProfileViewModel, Error>) -> Void) {
        
        let fulfillCompletionOnTheMainThread: (Result<ProfileViewModel, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let request = createURLRequest() else {
            assertionFailure("Error: unable to create URL request")
            print("Error: unable to create URL request")
            return
        }
        
        networkClient.performRequest(serviceType: ServiceType.profile, request: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfileResult.self, from: data)
                    guard let profile = self?.createProfileViewModel(from: response) else {
                        assertionFailure("Error: unable to create Profile View Model")
                        print("Error: unable to create Profile View Model")
                        return
                    }
                    fulfillCompletionOnTheMainThread(.success(profile))
                } catch {
                    fulfillCompletionOnTheMainThread(.failure(error))
                    assertionFailure("Error: decoding error \(error)")
                    print("Error: decoding error \(error)")
                }
            case .failure(let error):
                fulfillCompletionOnTheMainThread(.failure(error))
                assertionFailure("Error: \(error)")
                print("Error: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func createURLRequest() -> URLRequest? {
        guard let authToken = OAuth2TokenStorage.token else {
            assertionFailure("Error: authorization (bearer) token is not found")
            print("Error: authorization (bearer) token is not found")
            return nil
        }
        let url = Constants.defaultBaseURL.appendingPathComponent("me")
        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func createProfileViewModel(from response: ProfileResult) -> ProfileViewModel {
        return ProfileViewModel(username: response.username,
                                name: response.firstName + " " + response.lastName,
                                loginName: "@" + response.username,
                                bio: response.bio)
    }
    
}
