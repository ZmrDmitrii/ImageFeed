//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/8/24.
//
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    static private(set) var imageSizes: [CGSize] = []
    
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var cellLikeButton: UIButton!
    @IBOutlet private weak var cellDateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
    }
    
    func configure(with model: ImageViewModel, completion: () -> Void) {
//        guard let image = UIImage(named: model.imageName) else {
//            assertionFailure("Error: image is not found")
//            return
//        }
        // TODO: Проверить, правильно ли я настроил активити индикатор?
        cellImageView.kf.indicatorType = .activity
        // TODO: Разобраться, закругление изображений дает сториборд или нужно использовать processor
        cellImageView.kf.setImage(with: model.thumbnailURL,
                                  placeholder: UIImage.cardStub,
                                  completionHandler: { result in
//            switch result {
//            case .success(let value):
//                let imageSize = value.image.size
//                print("Image's width is \(imageSize.width)")
//                print("Image's height is \(imageSize.height)")
////                ImagesListCell.imageSizes.append(imageSize)
//            case .failure(let error):
//                assertionFailure("Error: unable to get image size; \(error)")
//                print("Error: unable to get image size; \(error)")
//            }
        })
        cellDateLabel.text = model.date
        cellLikeButton.setImage(
            model.isLiked ? UIImage(named: "Active") : UIImage(named: "No Active"),
            for: .normal
        )
        cellLikeButton.setTitle("", for: .normal)
    }
}
