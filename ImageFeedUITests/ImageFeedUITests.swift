//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Дмитрий Замараев on 30/10/24.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    // Перед запуском включить английскую раскладку на маке
    func testAuth() throws {

        let authButton = app.buttons["Authenticate"]
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        // TODO: заменить
        loginTextField.typeText("your login")
        loginTextField.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        passwordTextField.tap()
        sleep(5)
        // TODO: Заменить
        passwordTextField.typeText("your password")
        passwordTextField.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        
        print(app.debugDescription)
    }
    
    func testFeed() throws {
        
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.element.waitForExistence(timeout: 10))
        
        let cell1 = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell1.swipeUp()
        XCTAssertTrue(cell1.waitForExistence(timeout: 10))
        
        let cell3 = tablesQuery.children(matching: .cell).element(boundBy: 2)
        
        let likeButton = cell3.buttons["Like"]
        let initialLikeImage = likeButton.screenshot().pngRepresentation
        likeButton.tap()
        sleep(5)
        XCTAssertNotEqual(initialLikeImage, likeButton.screenshot().pngRepresentation)
        
        likeButton.tap()
        sleep(5)
        XCTAssertEqual(initialLikeImage, likeButton.screenshot().pngRepresentation)
        
        cell3.tap()
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10))
        image.pinch(withScale: 3, velocity: 1)
        sleep(3)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(3)
        
        let backButton = app.buttons["Back"]
        backButton.tap()
        
        let tablesQueryNew = app.tables
        let cellNew = tablesQueryNew.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cellNew.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
    }
    
    func testProfile() throws {
        
        let tabBar = app.tabBars
        let profileButton = tabBar.buttons.element(boundBy: 1)
        XCTAssertTrue(profileButton.waitForExistence(timeout: 10))
        profileButton.tap()
        
        // TODO: Заменить
        XCTAssertTrue(app.staticTexts["your name"].exists)
        XCTAssertTrue(app.staticTexts["your username"].exists)
        
        let exitButton = app.buttons["Exit"]
        exitButton.tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.exists)
        let yesButton = alert.scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(yesButton.exists)
        yesButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
    }
}
