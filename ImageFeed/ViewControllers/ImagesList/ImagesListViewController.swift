//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 4/8/24.
//
import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private properties
    private var imagesListServiceObserver: NSObjectProtocol?
    private(set) var photos: [PhotoViewModel] = []
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Date Formatter
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
        imagesListService.fetchPhotosNextPage()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                guard let self else { return }
                
                guard let userInfo = notification.userInfo,
                      let updatedPhotos = userInfo["photos"] as? [PhotoViewModel]
                else {
                          assertionFailure("Error: unable to get updated photos")
                          print("Error: unable to get updated photos")
                          return
                }
                self.updateTableViewAnimated(updatedPhotos: updatedPhotos)
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
    
    // MARK: - Private Methods
    private func updateTableViewAnimated(updatedPhotos: [PhotoViewModel]) {
        let oldCount = photos.count
        let newCount = updatedPhotos.count
        photos = updatedPhotos
        if oldCount != newCount && newCount != 0 {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        } else if newCount == 0 {
            let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func updateIsLikedProperty(photoID: String) {
        if let index = self.photos.firstIndex(where: { $0.id == photoID }) {
            DispatchQueue.main.async {
                let photo = self.photos[index]
                
                let newPhoto = PhotoViewModel(
                    id: photo.id,
                    createdAt: photo.createdAt,
                    size: photo.size,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: !photo.isLiked
                )
                
                self.photos[index] = newPhoto
            }
        }
    }
}

// MARK: UITableViewDataSource
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
        
        // TODO: Тут поменял thumbnail на large. Нужно поменять обратно, но не знаю что с размером
        let urls = photos.compactMap { URL(string: $0.largeImageURL) }
        let dates = photos.compactMap { $0.createdAt }
        
        
        let model = ImageViewModel(thumbnailURL: urls[indexPath.row],
                                   date: dateFormatter.string(from: dates[indexPath.row]),
                                   isLiked: photos[indexPath.row].isLiked)
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
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageWidth = CGFloat(photos[indexPath.row].size.width)
            
            /*UIImage(named: photosName[indexPath.row])?.size.width ?? 0*/
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
            print("Error: unable to get cell index")
            return
        }
        let photo = photos[indexPath.row]
        imagesListService.changeLike(photoID: photo.id, isLiked: photo.isLiked) { [weak self] result in
            switch result {
            case .success():
                self?.updateIsLikedProperty(photoID: photo.id)
                cell.setIsLiked()
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                // TODO: Показать ошибку с использованием UIAlertController
                assertionFailure("Error: unable to change like. \(error)")
                print("Error: unable to change like. \(error)")
            }
            
            
        }
    }
}
