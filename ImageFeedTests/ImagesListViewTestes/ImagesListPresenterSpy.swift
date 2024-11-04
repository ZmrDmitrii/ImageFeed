//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Дмитрий Замараев on 1/11/24.
//
import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var fetchPhotosCalled = false
    var updatePhotosCalled = false
    
    func createImageViewModel(indexPath: IndexPath, photos: [ImageFeed.PhotoViewModel]) -> ImageFeed.ImageViewModel {
        return ImageViewModel(thumbnailURL: URL(fileURLWithPath: String()), date: String(), isLiked: Bool())
    }
    
    func updatePhotos(updatedPhotos: [ImageFeed.PhotoViewModel]) {
        updatePhotosCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosCalled = true
    }
    
    func changeLike(photo: ImageFeed.PhotoViewModel, completion: @escaping (Result<Void, any Error>) -> Void) {
    }
}
