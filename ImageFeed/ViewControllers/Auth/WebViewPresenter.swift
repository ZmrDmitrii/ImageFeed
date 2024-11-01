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
     
    // MARK: - Internal Properties
    
    weak var view: (any WebViewViewControllerProtocol)?
    
    // MARK: - Private Properties
    
    private let authHelper: AuthHelperProtocol
    
    // MARK: - Initializers
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Internal Methods
    
    func viewDidLoad() {
        loadAuthView()
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let shouldHideProgress = shouldHideProgress(for: Float(newValue))
        view?.setProgressValue(Float(newValue))
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    // MARK: - Private Methods
    
    private func loadAuthView() {
        guard let request = authHelper.createAuthRequest() else {
            assertionFailure("Error: unable to create auth request")
            return
        }
        view?.load(request: request)
    }
}
