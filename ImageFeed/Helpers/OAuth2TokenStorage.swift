//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 10/9/24.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "accessToken")
        }
        set {
            guard let newValue else {
                // TODO: add alert
                assertionFailure("Error: unable to add access token to keychain")
                return
            }
            KeychainWrapper.standard.removeObject(forKey: "accessToken")
            if !newValue.isEmpty {
                KeychainWrapper.standard.set(newValue, forKey: "accessToken")
            }
        }
    }
}
