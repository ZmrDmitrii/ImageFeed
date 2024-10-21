//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 4/9/24.
//
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var logInButton: UIButton!
    
    // MARK: - Internal Properties
    
    weak var delegate: AuthViewControllerDelegate? = nil
    
    // MARK: - Private Properties
    
    private let oAuth2Service = OAuth2Service.shared
    
    // MARK: - Navigation
    
    // При нажатии на "Войти" AuthVC становится делегатом WebViewVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Error: invalid segue destination")
                return
            }
            let webViewPresenter = WebViewPresenter()
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true, completion: nil)
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchOAuthToken(code: code, completion: { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.delegate?.didAuthenticate(self)
                case .failure(let error):
                    print("Error: unable to log in. \(error)")
                    
                    let alert = UIAlertController(
                        title: "Что-то пошло не так",
                        message: "Не удалось войти в систему",
                        preferredStyle: .alert
                    )
                    let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        // Убираем с экрана WebViewViewController
        // AuthViewController инициировал показ, он и будет отвечать за скрытие - разделение ответственностей
        vc.dismiss(animated: true, completion: nil)
    }
}
