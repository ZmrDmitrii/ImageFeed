//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Public Properties
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    // ленивая инициализация - объект будет создан при обращении к нему; разрывает цикл зависимостей
    private lazy var networkClient: NetworkRouting = NetworkClient()
    
    var task: URLSessionTask?
    var lastCode: String?
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
                
        guard let request = createURLRequest(code: code) else {
            assertionFailure("Error: failed to create URL Request")
            print("Error: failed to create URL Request")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = networkClient.performRequestAndDecode(
            request: request
        ) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let response):
                OAuth2TokenStorage.token = response.accessToken
                completion(.success(response.accessToken))
            case .failure(let error):
                assertionFailure("Error: \(error)")
                print("Error: \(error)")
                completion(.failure(error))
            }
            
            self.task = nil
            self.lastCode = nil
        }
    }
    
    // MARK: - Private Methods
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
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
