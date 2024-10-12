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
//    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [PhotoViewModel] = []
    
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
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                guard let self else { return }
                
                if let userInfo = notification.userInfo,
                   let updatedPhotos = userInfo["photos"] as? [PhotoViewModel] {
                    self.updateTableViewAnimated(updatedPhotos: updatedPhotos)
                }
                
                
            }
        )
    }
    
    // MARK: - Navigation
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
    
    // MARK: - Private Methods
    private func updateTableViewAnimated(updatedPhotos: [PhotoViewModel]) {
        let oldCount = photos.count
        let newCount = updatedPhotos.count
        photos = updatedPhotos
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
        // Сюда передается массив photos. Нужно как-то сделать чтобы эти фото отображались в таблице.
    }
}

// MARK: UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    // TODO: реализовать с использованием photos
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    // TODO: реализовать с использованием photos
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // TODO: Добавить функционал вызова функции из ImageListService
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
