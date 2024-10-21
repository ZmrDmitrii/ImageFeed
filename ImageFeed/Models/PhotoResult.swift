//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 11/10/24.
//
import Foundation

struct URLResult: Decodable {
    let full: String
    let small: String
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let description: String?
    let isLiked: Bool
    let urls: URLResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case isLiked = "liked_by_user"
        case urls
    }
}

