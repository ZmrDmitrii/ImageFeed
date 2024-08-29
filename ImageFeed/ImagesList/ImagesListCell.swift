//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/8/24.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var cellLikeButton: UIButton!
    @IBOutlet private weak var cellDateLable: UILabel!
    
    func configure(with model: ImageViewModel) {
        guard let image = UIImage(named: model.imageName) else {
            print("Image is't found")
            return
        }
        cellImageView.image = image
        cellDateLable.text = model.date
        cellLikeButton.setImage(model.isLiked ? UIImage(named: "Active") : UIImage(named: "No Active"),
                                for: .normal)
        cellLikeButton.setTitle("", for: .normal)
    }
}
