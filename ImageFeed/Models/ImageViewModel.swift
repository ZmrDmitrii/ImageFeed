//
//  ImageViewModel.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 17/8/24.
//
import Foundation

struct ImageViewModel: Equatable {
    let thumbnailURL: URL
    let date: String
    let isLiked: Bool
}
