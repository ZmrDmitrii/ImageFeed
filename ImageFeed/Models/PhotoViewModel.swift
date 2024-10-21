//
//  PhotoViewModel.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/10/24.
//
import Foundation

struct PhotoViewModel {
    let id: String
    let createdAt: Date?
    let size: CGSize
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
