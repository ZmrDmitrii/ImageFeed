//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 4/8/24.
//
import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var photos: [PhotoViewModel] { get set }
    func addRows(indexPaths: [IndexPath])
    func removeRows(indexPaths: [IndexPath])
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Internal Properties
    
    var photos: [PhotoViewModel] = []
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Private properties
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
        presenter?.fetchPhotosNextPage()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                guard let self,
                      let userInfo = notification.userInfo,
                      let updatedPhotos = userInfo["photos"] as? [PhotoViewModel]
                else {
                    assertionFailure("Error: unable to get updated photos")
                    return
                }
                presenter?.updatePhotos(updatedPhotos: updatedPhotos)
            }
        )
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showSingleImageSegueIdentifier {
            guard
                let singleImageViewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Error: invalid segue destination")
                return
            }
            let imageURL = photos[indexPath.row].largeImageURL
            singleImageViewController.imageURL = URL(string: imageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Internal Methods
    
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func addRows(indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func removeRows(indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            assertionFailure("Error: failed to cast the cell to the required type")
            return UITableViewCell()
        }
        
        imagesListCell.delegate = self
        
        guard let model = presenter?.createImageViewModel(indexPath: indexPath, photos: photos) else {
            assertionFailure("Error: unable to create ImageViewModel")
            return UITableViewCell()
        }
        
        imagesListCell.configure(with: model) {
            // Перезагружаю ячейку после загрузки в нее фото, чтобы обновилась высота
            DispatchQueue.main.async {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        return imagesListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (photos.count - 1) {
            presenter?.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageWidth = CGFloat(photos[indexPath.row].size.width)
        let imageViewWidth = CGFloat(tableView.contentSize.width)
        let imageHeight = CGFloat(photos[indexPath.row].size.height)
        return imageHeight * (imageViewWidth / imageWidth)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showSingleImageSegueIdentifier, sender: indexPath)
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegateProtocol{
    func imagesListCellDidTapLike(cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure("Error: unable to get cell index")
            return
        }
        let photo = photos[indexPath.row]
        presenter?.changeLike(photo: photo) { result in
            switch result {
            case .success():
                cell.setIsLiked()
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                // TODO: Показать ошибку с использованием UIAlertController
                assertionFailure("Error: unable to change like. \(error)")
            }
        }
    }
}
