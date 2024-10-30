//
//  ImagesListViewTestes.swift
//  ImagesListViewTestes
//
//  Created by Дмитрий Замараев on 30/10/24.
//
import XCTest
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

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var photos: [PhotoViewModel] = []
    var addRowsCalled = false
    var removeRowsCalled = false
    
    func addRows(indexPaths: [IndexPath]) {
        addRowsCalled = true
    }
    
    func removeRows(indexPaths: [IndexPath]) {
        removeRowsCalled = true
    }
}

final class ImagesListViewTestes: XCTestCase {
    
    func testViewControllerCallsFetchPhotos() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        imagesListViewController.configure(presenter: presenter)
        
        //When
        _ = imagesListViewController.view
        
        //Then
        XCTAssertTrue(presenter.fetchPhotosCalled)
    }
    
    func testViewControllerCallsFetchPhotosWhenTableViewWillDisplay() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        let photo = PhotoViewModel(id: "test", createdAt: nil, size: CGSize(), welcomeDescription: nil, thumbImageURL: "test", largeImageURL: "test", isLiked: Bool())
        imagesListViewController.configure(presenter: presenter)
        imagesListViewController.photos = [photo]
        
        //When
        imagesListViewController.tableView(UITableView(), willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        
        //Then
        XCTAssertTrue(presenter.fetchPhotosCalled)
    }
    
    func testViewControllerCallsUpdatePhotosWhenNotificationPosted() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        imagesListViewController.configure(presenter: presenter)
        
        //When
        _ = imagesListViewController.view
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                        object: nil,
                                        userInfo: ["photos": []])
        
        //Then
        XCTAssertTrue(presenter.updatePhotosCalled)
    }
    
    func testPresenterCallsAddRows() {
        //Given
        let imagesListViewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesListHelper: ImagesListHelper())
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        let photo = PhotoViewModel(id: "test", createdAt: nil, size: CGSize(), welcomeDescription: nil, thumbImageURL: "test", largeImageURL: "test", isLiked: Bool())
        let updatedPhotos = [photo]
        
        //When
        presenter.updatePhotos(updatedPhotos: updatedPhotos)
        
        //Then
        XCTAssertTrue(imagesListViewController.addRowsCalled)
    }
    
    func testPresenterCallsRemoveRows() {
        //Given
        let imagesListViewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesListHelper: ImagesListHelper())
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        let updatedPhotos: [PhotoViewModel] = []
        
        //When
        presenter.updatePhotos(updatedPhotos: updatedPhotos)
        
        //Then
        XCTAssertTrue(imagesListViewController.removeRowsCalled)
    }
    
    func testCreateImageViewModel() {
        //Given
        let imageListHelper = ImagesListHelper()
        let photo = [PhotoViewModel(id: String(), createdAt: Date(), size: CGSize(), welcomeDescription: nil, thumbImageURL: "test", largeImageURL: String(), isLiked: true)]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let testImageViewModel = ImageViewModel(
            thumbnailURL: URL(string: "test") ?? URL(fileURLWithPath: String()),
            date: dateFormatter.string(from: Date()) ,
            isLiked: true
        )
        
        //When
        let imageViewModel = imageListHelper.createImageViewModel(indexPath: IndexPath(row: 0, section: 0), photos: photo)
        
        //Then
        XCTAssertEqual(imageViewModel, testImageViewModel)
    }
    
    func testUpdateIsLikedInModel() {
        //Given
        let imageListHelper = ImagesListHelper()
        let photo = PhotoViewModel(id: String(), createdAt: nil, size: CGSize(), welcomeDescription: nil, thumbImageURL: String(), largeImageURL: String(), isLiked: true)
        
        //When
        let changedPhoto = imageListHelper.updateIsLikedInModel(photo: photo)
        
        //Then
        XCTAssertFalse(changedPhoto.isLiked)
    }
    
}
