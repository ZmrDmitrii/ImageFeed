//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Дмитрий Замараев on 25/10/24.
//
import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        profileViewController.configure(presenter: presenter)
        
        //When
        _ = profileViewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCallsCounter == 1)
    }
    
    func testViewControllerCallsCreateAlert() {
        //Given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        profileViewController.configure(presenter: presenter)
        
        //When
        profileViewController.didTapExitButton()
        
        //Then
        XCTAssertTrue(presenter.createAlertCalled)
    }
    
    func testPresenterCallUpdateProfileData() {
        //Given
        let profileViewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        ProfileStorage.profile = ProfileViewModel(username: "test_username",
                                                  name: "test_name",
                                                  loginName: "test_loginName",
                                                  bio: "test_bio")
        ProfileStorage.avatarURL = "test_url"
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(profileViewController.updateProfileDataCalled)
    }
    
    func testPresenterCallUpdateAvatar() {
        //Given
        let profileViewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        profileViewController.presenter = presenter
        presenter.view = profileViewController
        ProfileStorage.profile = ProfileViewModel(username: "test_username",
                                                  name: "test_name",
                                                  loginName: "test_loginName",
                                                  bio: "test_bio")
        ProfileStorage.avatarURL = "test_url"
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(profileViewController.updateAvatarCalled)
    }
    
    func testControllerObserverCallsViewDidLoad() {
        //Given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        profileViewController.configure(presenter: presenter)
        
        //When
        _ = profileViewController.view
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                        object: nil,
                                        userInfo: nil)
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCallsCounter == 2)
    }
    
    func testCreateExitAlert() {
        //Given
        let profileViewController = ProfileViewController()
        let presenter = ProfileViewPresenter()
        profileViewController.configure(presenter: presenter)
        
        //When
        let alert = presenter.createExitAlert()
        
        let yesAction = alert.actions[0]
        let noAction = alert.actions[1]
        
        //Then
        XCTAssertEqual(alert.title, "Пока, пока!")
        XCTAssertEqual(alert.message, "Уверены что хотите выйти?")
        XCTAssertEqual(yesAction.title, "Да")
        XCTAssertEqual(noAction.title, "Нет")
        XCTAssertEqual(noAction.style, .cancel)
    }
}
