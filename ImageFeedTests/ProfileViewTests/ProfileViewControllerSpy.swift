//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Дмитрий Замараев on 1/11/24.
//
import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: (any ImageFeed.ProfileViewPresenterProtocol)?
    var updateProfileDataCalled: Bool = false
    var updateAvatarCalled: Bool = false
    
    func updateProfileData(username: String, name: String, loginName: String, bio: String?) {
        updateProfileDataCalled = true
    }
    
    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }
}
