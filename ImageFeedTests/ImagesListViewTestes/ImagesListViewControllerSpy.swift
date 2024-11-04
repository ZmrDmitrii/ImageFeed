//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Дмитрий Замараев on 1/11/24.
//
import Foundation
@testable import ImageFeed

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
