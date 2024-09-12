//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 5/9/24.
//
import Foundation

// Протокол отвечает за обработку получения параметра с именем "code"
protocol WebViewViewControllerDelegate: AnyObject {
    // WebViewViewController получил "code"
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    // Пользователь нажал кнопку назад и отменил авторизацию
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
