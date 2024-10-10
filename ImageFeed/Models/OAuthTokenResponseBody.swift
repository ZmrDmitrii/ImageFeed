//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
