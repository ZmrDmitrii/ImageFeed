//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Дмитрий Замараев on 1/11/24.
//
import UIKit
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: (any ImageFeed.ProfileViewControllerProtocol)?
    var createAlertCalled: Bool = false
    var viewDidLoadCallsCounter = 0
    
    func viewDidLoad() {
        viewDidLoadCallsCounter += 1
    }
    
    func createExitAlert() -> UIAlertController {
        createAlertCalled = true
        return UIAlertController(title: "test", message: "test", preferredStyle: .alert)
    }
}
