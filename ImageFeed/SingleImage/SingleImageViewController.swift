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
                print("image is not found")
                return
            }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        guard let image else {
            print("image is not found")
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
            print("image is not found")
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
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        scrollView.contentInset.left = (visibleRectangleSize.width - newContentSize.width) / 2
        scrollView.contentInset.top = (visibleRectangleSize.height - newContentSize.height) / 2
        scrollView.contentInset.bottom = (visibleRectangleSize.height - newContentSize.height) / 2
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
        
        if scrollView.contentSize.height <= visibleRectangleSize.height {
            scrollView.contentInset.top = (visibleRectangleSize.height - contentSize.height) / 2
            scrollView.contentInset.bottom = (visibleRectangleSize.height - contentSize.height) / 2
        } else {
            scrollView.contentInset.top = 0
            scrollView.contentInset.bottom = 0
        }
    
        if scrollView.contentSize.width < visibleRectangleSize.width {
            scrollView.contentInset.left = (visibleRectangleSize.width - contentSize.width) / 2
            scrollView.contentInset.right = (visibleRectangleSize.width - contentSize.width) / 2
        } else {
            scrollView.contentInset.left = 0
            scrollView.contentInset.right = 0
        }
    }
}
