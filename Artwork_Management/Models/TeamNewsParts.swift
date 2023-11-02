//
//  TeamNewsParts.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/10/27.
//

import Foundation

/// Homeのチーム情報パーツのユーザー設定を管理する
struct TeamNewsParts: Codable, Hashable {
    var transitionOffset: CGSize = .zero
    var initialOffset: CGSize = .zero
    var transitionScale: CGFloat = 1.0
    var initialScale: CGFloat = 1.0
    var desplayState: Bool = true
    var backState: Bool = true
    var pressingAnimation: Bool = false
}
