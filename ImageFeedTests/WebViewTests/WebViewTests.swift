//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Дмитрий Замараев on 22/10/24.
//
import XCTest
@testable import ImageFeed

final class ImageFeedTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        webViewController.presenter = presenter
        presenter.view = webViewController
        
        //When
        _ = webViewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallLoadRequest() {
        //Given
        let webViewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        webViewController.presenter = presenter
        presenter.view = webViewController
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(webViewController.loadCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //Given
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        let progress: Float = 0.1
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //Given
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        let progress = Float(1.0)
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //Given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper()
        
        //When
        let url = authHelper.createAuthURL()
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        //Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //Given
        let authHelper = AuthHelper()
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = urlComponents?.url else {
            XCTFail("Unable to get url with test code")
            return
        }
        
        //When
        let code = authHelper.code(from: url)
        
        //Then
        XCTAssertEqual(code, "test code")
    }
}
