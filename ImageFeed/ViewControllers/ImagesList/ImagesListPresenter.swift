//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 26/10/24.
//
import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func createImageViewModel(indexPath: IndexPath, photos: [PhotoViewModel]) -> ImageViewModel
    func updatePhotos(updatedPhotos: [PhotoViewModel])
    func fetchPhotosNextPage()
    func changeLike(photo: PhotoViewModel, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Internal Properties
    
    var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private let imagesListService = ImagesListService.shared
    private var imagesListHelper: ImagesListHelperProtocol
    
    // MARK: - Initializers
    
    init(imagesListHelper: ImagesListHelperProtocol) {
        self.imagesListHelper = imagesListHelper
    }
    
    // MARK: - Internal Methods
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func createImageViewModel(indexPath: IndexPath, photos: [PhotoViewModel]) -> ImageViewModel {
        imagesListHelper.createImageViewModel(indexPath: indexPath, photos: photos)
    }
    
    func updatePhotos(updatedPhotos: [PhotoViewModel]) {
        guard let oldCount = view?.photos.count else {
            assertionFailure("Error: unable to get old count of photos")
            return
        }
        let newCount = updatedPhotos.count
        view?.photos = updatedPhotos
        
        if oldCount != newCount && newCount != 0 {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.addRows(indexPaths: indexPaths)
        } else if newCount == 0 {
            let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
            view?.removeRows(indexPaths: indexPaths)
        }
    }
    
    func changeLike(photo: PhotoViewModel, completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService.changeLike(photoID: photo.id, isLiked: photo.isLiked) { [weak self] result in
            switch result {
            case .success():
                self?.updateIsLikedProperty(photoID: photo.id)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateIsLikedProperty(photoID: String) {
        if let index = view?.photos.firstIndex(where: { $0.id == photoID }) {
            DispatchQueue.main.async {
                guard let photo = self.view?.photos[index] else {
                    assertionFailure("Error: unable to get a photo")
                    return
                }
                let newPhoto = self.imagesListHelper.updateIsLikedInModel(photo: photo)
                self.view?.photos[index] = newPhoto
                self.imagesListService.photos[index] = newPhoto
            }
        }
    }
}
