//
//  Constants.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 3/9/24.
//
import Foundation

enum Constants {
    static let showSingleImageSegueIdentifier = "ShowSingleImage"
    static let showWebViewSegueIdentifier = "ShowWebView"
    
    static let accessKey = "91eGFkO9Z4u9W3P_bSijt1178ZD9QyMoqwelQu0iE0w"
    static let secretKey = "-Zuy1DVj71P0ZawFAbBYJDOWjV2s5dlDciEehB1bNio"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL? = URL(string: "https://api.unsplash.com/")
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashRequestAccessTokenURLString = "https://unsplash.com/oauth/token"
    
    static let authVCIdentifier = "authVC"
    static let tabBarVCIdentifier = "tabBarVC"
}
