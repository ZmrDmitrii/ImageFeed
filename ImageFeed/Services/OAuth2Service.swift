//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let networkClient: NetworkRouting
    
    private init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private func createURLRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashRequestAccessTokenURLString) else {
            assertionFailure("Error: failed to get unsplashRequestAccessTokenURLString")
            print("Error: failed to get unsplashRequestAccessTokenURLString")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Error: failed to get url")
            print("Error: failed to get url")
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let fulfillCompletionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let request = createURLRequest(code: code) else {
            assertionFailure("Error: failed to create URL Request")
            print("Error: failed to create URL Request")
            return
        }
        
        networkClient.fetch(request: request, handler: { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.token = response.accessToken
                    fulfillCompletionOnTheMainThread(.success(response.accessToken))
                } catch {
                    fulfillCompletionOnTheMainThread(.failure(error))
                    print("Error: decoding error \(error)")
                }
            case .failure(let error):
                fulfillCompletionOnTheMainThread(.failure(error))
                print("Error: \(error)")
            }
        })
    }
}
