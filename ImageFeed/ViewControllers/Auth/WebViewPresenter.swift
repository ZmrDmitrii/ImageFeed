//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 21/10/24.
//
import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
     
    var view: (any WebViewViewControllerProtocol)?
    
    // MARK: - Internal Methods
    
    func viewDidLoad() {
        loadAuthView()
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let shouldHideProgress = shouldHideProgress(for: Float(newValue))
        view?.setProgressValue(Float(newValue))
        view?.setProgressHidden(shouldHideProgress)
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
    
    // MARK: - Private Methods
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            assertionFailure("Error: failed to get unsplashAuthorizeURLString")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Error: failed to get url")
            return
        }
        
        let request = URLRequest(url: url)
        view?.load(request: request)
    }
    
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
