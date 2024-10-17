//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/8/24.
//
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var cellLikeButton: UIButton!
    @IBOutlet private weak var cellDateLabel: UILabel!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegateProtocol?
    
    // MARK: - Private Properties
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Override methods
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
    }
    
    // MARK: - IBActions
    @IBAction private func didTapLikeButton(_ sender: UIButton) {
        delegate?.imagesListCellDidTapLike(cell: self)
        UIBlockingProgressHUD.show()
    }
    
    // MARK: - Public Methods
    func configure(with model: ImageViewModel, completion: () -> Void) {
        cellImageView.kf.indicatorType = .activity
        cellImageView.kf.setImage(with: model.thumbnailURL,
                                  placeholder: UIImage.cardStub)
        cellDateLabel.text = model.date
        cellLikeButton.setImage(
            model.isLiked ? UIImage.likeActive : UIImage.likeNoActive,
            for: .normal
        )
        cellLikeButton.setTitle("", for: .normal)
    }
    
    func setIsLiked() {
        if cellLikeButton.image(for: .normal) == UIImage.likeActive {
            cellLikeButton.setImage(UIImage.likeNoActive, for: .normal)
        } else {
            cellLikeButton.setImage(UIImage.likeActive, for: .normal)
        }
    }
}
