//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 16/10/24.
//
import Foundation
import WebKit


final class ProfileLogoutService {
    
    // MARK: - Public Properties
    static let shared = ProfileLogoutService()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func logout() {
        cleanTokenStorage()
        cleanProfileInfo()
        cleanImagesList()
        cleanCookies()
        goToSplashScreen()
    }
    
    // MARK: - Private Methods
    private func cleanTokenStorage() {
        OAuth2TokenStorage.token = ""
    }
    
    private func cleanProfileInfo() {
        ProfileStorage.profile = nil
        ProfileStorage.avatarURL = nil
    }
    private func cleanImagesList() {
        ImagesListService.shared.cleanPhotos()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                        for: [record],
                                                        completionHandler: {})
            }
        }
    }
    
    private func goToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let initialViewController = SplashViewController()
        window.rootViewController = initialViewController
    }
}
