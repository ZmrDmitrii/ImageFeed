//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Дмитрий Замараев on 1/11/24.
//
import Foundation
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: (any ImageFeed.WebViewViewControllerProtocol)?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from url: URL) -> String? { return nil }
}
