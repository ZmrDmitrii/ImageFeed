//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 17/8/24.
//
import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exitButton.setTitle("", for: .normal)
    }
    
    @IBAction func didTapExitButton(_ sender: Any) {
    }
    
}

