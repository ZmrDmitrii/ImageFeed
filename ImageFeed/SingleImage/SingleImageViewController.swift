//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 22/8/24.
//
import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    // MARK: - Public Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            guard let image else {
                assertionFailure("Error: image is not found")
                return
            }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        guard let image else {
            assertionFailure("Error: image is not found")
            return
        }
        imageView.frame.size = image.size
        backButton.setTitle("", for: .normal)
        shareButton.setTitle("", for: .normal)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - IB Actions
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {
            assertionFailure("Error: image is not found")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        let visibleRectangleSize = scrollView.bounds.size
        let hScale = visibleRectangleSize.height / image.size.height
        let wScale = visibleRectangleSize.width / image.size.width
        let minScale = scrollView.minimumZoomScale
        let maxScale = scrollView.maximumZoomScale
        let theoreticalScale = min(hScale, wScale)
        let scale = min(maxScale, max(minScale, theoreticalScale))
        scrollView.setZoomScale(scale, animated: false)
        updateScrollViewInsets(rectangleSize: visibleRectangleSize, newContentSize: scrollView.contentSize)
    }
    
    private func updateScrollViewInsets(rectangleSize: CGSize, newContentSize: CGSize) {
        scrollView.contentInset.left = (rectangleSize.width - newContentSize.width) / 2
        scrollView.contentInset.right = scrollView.contentInset.left
        scrollView.contentInset.top = (rectangleSize.height - newContentSize.height) / 2
        scrollView.contentInset.bottom = scrollView.contentInset.top
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let visibleRectangleSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        scrollView.contentInset.top = max((visibleRectangleSize.height - contentSize.height) / 2, 0)
        scrollView.contentInset.bottom = scrollView.contentInset.top
        scrollView.contentInset.left = max((visibleRectangleSize.width - contentSize.width) / 2, 0)
        scrollView.contentInset.right = scrollView.contentInset.left
    }
}
