//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation

final class OAuth2TokenStorage {
    static var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "accessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }
}
