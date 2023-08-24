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
public func reviewApp() {
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

public func infomation() {

}

