//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 22/10/24.
//
import Foundation

protocol AuthHelperProtocol {
    func createAuthRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    
    // MARK: - Private Properties
    
    private let configuration: AuthConfiguration
    
    // MARK: - Initializers
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Internal Methods
    
    func createAuthRequest() -> URLRequest? {
        guard let url = createAuthURL() else {
            assertionFailure("Error: failed to create auth URL")
            return nil
        }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        // Превращаем этот URL в структуру URLComponents, чтобы проще было работать с его компонентами
        // Проверяем соответствует ли путь в URL тому, который мы ожидаем для получения кода авторизации
        // Проверяем есть ли у URL параметры (query items), которые могли бы содержать код
        // Среди всех параметров (query items) ищем такой, у которого имя "code"
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    func createAuthURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            assertionFailure("Error: failed to get unsplashAuthorizeURLString")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
}
