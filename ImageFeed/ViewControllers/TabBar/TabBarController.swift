//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 9/10/24.
//
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        else {
            assertionFailure("Error: unable to create ImagesListViewController")
            return
        }
        let imagesListPresenter = ImagesListPresenter(imagesListHelper: ImagesListHelper())
        imagesListViewController.configure(presenter: imagesListPresenter)
        
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenter()
        profileViewController.configure(presenter: profileViewPresenter)
        profileViewController.tabBarItem = UITabBarItem(title: "",
                                                        image: UIImage.tabProfileActive,
                                                        selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
