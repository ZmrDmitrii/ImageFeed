//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 26/9/24.
//
import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
