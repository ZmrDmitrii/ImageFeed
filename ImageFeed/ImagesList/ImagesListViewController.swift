//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 4/8/24.
//
import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    // MARK: - Date Formatter
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    //MARK: - Constants
    private enum Constants {
        static let showSingleImageSegueIdentifier = "ShowSingleImage"
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0)
        tableView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Override methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Error: invalid segue destination")
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            assertionFailure("Error: failed to cast the cell to the required type")
            return UITableViewCell()
        }
        
        let model = ImageViewModel(imageName: photosName[indexPath.row],
                                   date: dateFormatter.string(from: Date()),
                                   isLiked: (indexPath.row + 1) % 2 == 0)
        imagesListCell.configure(with: model)
        
        return imagesListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageWidth = CGFloat(UIImage(named: photosName[indexPath.row])?.size.width ?? 0)
        let imageViewWidth = CGFloat(tableView.contentSize.width)
        let imageHeight = CGFloat(UIImage(named: photosName[indexPath.row])?.size.height ?? 0)
        return imageHeight * (imageViewWidth / imageWidth)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showSingleImageSegueIdentifier, sender: indexPath)
    }
}
