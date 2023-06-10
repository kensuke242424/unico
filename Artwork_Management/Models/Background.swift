//
//  Background.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/09.
//

import SwiftUI

/// アプリ内のデフォルトで用意されている背景画像サンプル。
/// リサイズをおこなうため、UIImageで定義
enum TeamBackgroundContents: CaseIterable {
    case original, music, art, cafe, cool, cute, dark, technology

    var imageContents: [UIImage] {
        switch self {
        case .original:
            return [UIImage()]
        case .music:
            return Backgrounds.music
        case .art:
            return Backgrounds.art
        case .cafe:
            return Backgrounds.cafe
        case .cool:
            return Backgrounds.cool
        case .cute:
            return Backgrounds.cute
        case .dark:
            return Backgrounds.dark
        case .technology:
            return Backgrounds.technology
        }
    }
}

struct Backgrounds {

    static let cool: [UIImage] =
    [
        UIImage(named: "cool_1")!,
        UIImage(named: "cool_2")!,
        UIImage(named: "cool_3")!,
        UIImage(named: "cool_4")!,
        UIImage(named: "cool_5")!,
        UIImage(named: "cool_6")!,
        UIImage(named: "cool_7")!,
        UIImage(named: "cool_8")!,
        UIImage(named: "cool_9")!
    ]

    static let art: [UIImage] =
    [
        UIImage(named: "art_1")!,
        UIImage(named: "art_2")!,
        UIImage(named: "art_3")!,
        UIImage(named: "art_4")!,
        UIImage(named: "art_5")!,
        UIImage(named: "art_6")!,
        UIImage(named: "art_7")!,
        UIImage(named: "art_8")!,
        UIImage(named: "art_9")!,
        UIImage(named: "art_10")!
    ]

    static let cafe: [UIImage] =
    [
        UIImage(named: "cafe_1")!,
        UIImage(named: "cafe_2")!,
        UIImage(named: "cafe_3")!,
        UIImage(named: "cafe_4")!,
        UIImage(named: "cafe_5")!,
        UIImage(named: "cafe_6")!,
        UIImage(named: "cafe_7")!,
        UIImage(named: "cafe_8")!,
        UIImage(named: "cafe_9")!,
        UIImage(named: "cafe_10")!
    ]

    static let cute: [UIImage] =
    [
        UIImage(named: "cute_1")!,
        UIImage(named: "cute_2")!,
        UIImage(named: "cute_3")!,
        UIImage(named: "cute_4")!,
        UIImage(named: "cute_5")!,
        UIImage(named: "cute_6")!,
        UIImage(named: "cute_7")!,
        UIImage(named: "cute_8")!,
        UIImage(named: "cute_9")!,
        UIImage(named: "cute_10")!,
        UIImage(named: "cute_11")!,
        UIImage(named: "cute_12")!,
    ]

    static let dark: [UIImage] =
    [
        UIImage(named: "dark_1")!,
        UIImage(named: "dark_2")!,
        UIImage(named: "dark_3")!,
        UIImage(named: "dark_4")!,
        UIImage(named: "dark_5")!,
        UIImage(named: "dark_6")!,
        UIImage(named: "dark_7")!,
        UIImage(named: "dark_8")!,
        UIImage(named: "dark_9")!,
        UIImage(named: "dark_10")!
    ]

    static let music: [UIImage] =
    [
        UIImage(named: "music_1")!,
        UIImage(named: "music_2")!,
        UIImage(named: "music_3")!,
        UIImage(named: "music_4")!,
        UIImage(named: "music_5")!,
        UIImage(named: "music_6")!,
        UIImage(named: "music_7")!,
        UIImage(named: "music_8")!,
        UIImage(named: "music_9")!,
        UIImage(named: "music_10")!,
        UIImage(named: "music_11")!,
        UIImage(named: "music_12")!,
        UIImage(named: "music_13")!,
        UIImage(named: "music_14")!,
        UIImage(named: "music_15")!,
    ]

    static let technology: [UIImage] =
    [
        UIImage(named: "technology_1")!,
        UIImage(named: "technology_3")!,
        UIImage(named: "technology_4")!,
        UIImage(named: "technology_5")!,
        UIImage(named: "technology_6")!,
        UIImage(named: "technology_7")!,
        UIImage(named: "technology_8")!,
        UIImage(named: "technology_9")!,
        UIImage(named: "technology_10")!,
        UIImage(named: "technology_11")!,
    ]
}
