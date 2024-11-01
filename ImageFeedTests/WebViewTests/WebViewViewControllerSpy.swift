//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Дмитрий Замараев on 1/11/24.
//
import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: (any ImageFeed.WebViewPresenterProtocol)?
    var loadCalled: Bool = false
    
    func load(request: URLRequest) {
        loadCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    
    func setProgressHidden(_ isHidden: Bool) {}
}
