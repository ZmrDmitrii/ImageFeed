//
//  ImagesListHelper.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 29/10/24.
//
import Foundation

protocol ImagesListHelperProtocol {
    func updateIsLikedInModel(photo: PhotoViewModel) -> PhotoViewModel
    func createImageViewModel(indexPath: IndexPath, photos: [PhotoViewModel]) -> ImageViewModel
}

final class ImagesListHelper: ImagesListHelperProtocol {
    
    // MARK: - Private Properties
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Internal Methods
    
    func createImageViewModel(indexPath: IndexPath, photos: [PhotoViewModel]) -> ImageViewModel {
        let urls = photos.compactMap { URL(string: $0.thumbImageURL) }
        let dates = photos.compactMap { $0.createdAt }
        
        return ImageViewModel(thumbnailURL: urls[indexPath.row],
                              date: dateFormatter.string(from: dates[indexPath.row]),
                              isLiked: photos[indexPath.row].isLiked)
    }
    
    func updateIsLikedInModel(photo: PhotoViewModel) -> PhotoViewModel {
        PhotoViewModel(id: photo.id,
                       createdAt: photo.createdAt,
                       size: photo.size,
                       welcomeDescription: photo.welcomeDescription,
                       thumbImageURL: photo.thumbImageURL,
                       largeImageURL: photo.largeImageURL,
                       isLiked: !photo.isLiked)
    }
}
