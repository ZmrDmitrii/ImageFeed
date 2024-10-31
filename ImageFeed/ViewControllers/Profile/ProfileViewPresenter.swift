//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 22/10/24.
//
import Foundation
import UIKit

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func createExitAlert() -> UIAlertController
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    // MARK: - Internal Properties
    
    var view: ProfileViewControllerProtocol?
    
    // MARK: - Internal Methods
    
    func viewDidLoad() {
        updateProfileData()
        updateAvatar()
    }
    
    func createExitAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default, handler: { _ in
            ProfileLogoutService.shared.logout()
        })
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        return alert
    }
    
    // MARK: - Private Methods
    
    private func updateProfileData() {
        guard let profile = ProfileStorage.profile else {
            assertionFailure("Error: unable to get profile data")
            return
        }
        view?.updateProfileData(username: profile.username,
                                name: profile.name,
                                loginName: profile.loginName,
                                bio: profile.bio)
    }
    
    private func updateAvatar() {
        guard let avatarURL = ProfileStorage.avatarURL,
              let url = URL(string: avatarURL)
        else {
            assertionFailure("Error: unable to get avatar URL")
            return
        }
        view?.updateAvatar(url: url)
    }
}
