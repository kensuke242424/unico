//
//  ExternalManager.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/18.
//
// 外部サイトやページに接続する操作を管理する関数群。

import SwiftUI

/// unicoアプリケーションのシェアシート画面を表示する。
public func shareApp() {
    let productURL:URL = URL(string: "https://apps.apple.com/us/app/unico/id1663765686")!

    let activityViewController = UIActivityViewController(
        activityItems: [productURL],
        applicationActivities: nil)

    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first

    if let window {
        window.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

/// App Storeのアプリレビュー画面と接続するメソッド。
public func requestReviewAppStore() {
    let productURL:URL = URL(string: "https://apps.apple.com/us/app/unico/id1663765686")!

    var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)

    components?.queryItems = [
        URLQueryItem(name: "action", value: "write-review")
    ]

    guard let writeReviewURL = components?.url else {
        return
    }

    UIApplication.shared.open(writeReviewURL)
}

/// unico公式HPの問い合わせフォームに接続する。
public func sendContactUs() {
    let productURL:URL = URL(string: "https://kennsuke242424.wixsite.com/mysite/blank-2")!

    var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)

    components?.queryItems = [
        URLQueryItem(name: "action", value: "write-review")
    ]

    guard let writeReviewURL = components?.url else {
        return
    }

    UIApplication.shared.open(writeReviewURL)
}

/// unico公式HPの利用規約ページに接続する。
public func sendTermsOfUse() {
    let productURL:URL = URL(string: "https://kennsuke242424.wixsite.com/mysite/%E5%88%A9%E7%94%A8%E8%A6%8F%E7%B4%84")!

    var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)

    components?.queryItems = [
        URLQueryItem(name: "action", value: "write-review")
    ]

    guard let writeReviewURL = components?.url else {
        return
    }

    UIApplication.shared.open(writeReviewURL)
}

/// unico公式HPのプライバシーポリシーページに接続する。
public func sendPrivacyPolicy() {
    let productURL:URL = URL(string: "https://kennsuke242424.wixsite.com/mysite/%E3%83%97%E3%83%A9%E3%82%A4%E3%83%90%E3%82%B7%E3%83%BC%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC")!

    var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)

    components?.queryItems = [
        URLQueryItem(name: "action", value: "write-review")
    ]

    guard let writeReviewURL = components?.url else {
        return
    }

    UIApplication.shared.open(writeReviewURL)
}
