//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/8/24.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLikeButton: UIButton!
    @IBOutlet weak var cellDateLable: UILabel!
}
