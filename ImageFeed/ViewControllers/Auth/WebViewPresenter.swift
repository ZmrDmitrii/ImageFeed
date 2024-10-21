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
