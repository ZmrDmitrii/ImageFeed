//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    
    // MARK: - View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OAuth2TokenStorage.token != nil {
            fetchProfile()
        } else {
            let authViewController = storyboard?.instantiateViewController(withIdentifier: Constants.authVCIdentifier) as? AuthViewController
            authViewController?.delegate = self
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
        fetchProfile()
    }
    
    private func fetchProfile() {
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
            self.profileService.fetchProfile() { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self else { return }
                
                switch result {
                case .success(let profile):
                    self.switchToTabBarController()
                    ProfileStorage.profile = profile
                case .failure(let error):
                    // TODO: показ алерта
                    print("Error: show alert \(error)")
                    
                }
            }
        }
    }
}
