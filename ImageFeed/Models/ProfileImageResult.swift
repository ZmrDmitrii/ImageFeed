//
//  ProfileImageResult.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 1/10/24.
//
import Foundation

struct ImageSize: Codable {
    let small: String
}

struct ProfileImageResult: Decodable {
    let profileImage: ImageSize
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
