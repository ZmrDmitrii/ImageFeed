//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OAuth2TokenStorage.token != nil {
            // TODO: Загрузить необходимую информацию о пользователе
            switchToTabBarController()
        } else {
            let authViewController = storyboard?.instantiateViewController(withIdentifier: Constants.authVCIdentifier)
            authViewController?.modalPresentationStyle = .fullScreen
            present(authViewController ?? self, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarViewController = storyboard?.instantiateViewController(withIdentifier: Constants.tabBarVCIdentifier)
        
        window.rootViewController = tabBarViewController
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true, completion: nil)
        switchToTabBarController()
    }
}
