//
//  ImagesListCellDelegateProtocol.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 15/10/24.
//
import Foundation

protocol ImagesListCellDelegateProtocol: AnyObject {
    func imagesListCellDidTapLike(cell: ImagesListCell)
}
