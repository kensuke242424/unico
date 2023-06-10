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
    case original, music, art, cafe, beautiful, cool, cute, dark, technology

    var imageContents: [String] {
        switch self {
        case .original:
            return []
        case .music:
            return Backgrounds.music
        case .art:
            return Backgrounds.art
        case .cafe:
            return Backgrounds.cafe
        case .beautiful:
            return Backgrounds.beautiful
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

    static let cool: [String] =
    [
        "cool_1",
        "cool_2",
        "cool_3",
        "cool_4",
        "cool_5",
        "cool_6",
        "cool_7",
        "cool_8",
        "cool_9",
        "cool_10",
        "cool_11",
        "cool_12",
    ]

    static let art: [String] =
    [
        "art_1",
        "art_2",
        "art_3",
        "art_4",
        "art_5",
        "art_6",
        "art_7",
        "art_8",
        "art_9",
        "art_10",
        "art_11",
    ]

    static let cafe: [String] =
    [
        "cafe_1",
        "cafe_2",
        "cafe_3",
        "cafe_4",
        "cafe_5",
        "cafe_6",
        "cafe_7",
        "cafe_8",
        "cafe_9",
        "cafe_10",
    ]

    static let cute: [String] =
    [
        "cute_1",
        "cute_2",
        "cute_3",
        "cute_4",
        "cute_5",
        "cute_6",
        "cute_7",
        "cute_8",
        "cute_9",
        "cute_10",
        "cute_11",
        "cute_12",
        "cute_13",
    ]

    static let dark: [String] =
    [
        "dark_1",
        "dark_2",
        "dark_3",
        "dark_4",
        "dark_5",
        "dark_6",
        "dark_7",
        "dark_8",
        "dark_9",
        "dark_10",
        "dark_11",
    ]

    static let music: [String] =
    [
        "music_1",
        "music_2",
        "music_3",
        "music_4",
        "music_5",
        "music_6",
        "music_7",
        "music_8",
        "music_9",
        "music_10",
        "music_11",
        "music_12",
        "music_13",
        "music_14",
    ]

    static let beautiful: [String] =
    [
        "beautiful_1",
        "beautiful_2",
        "beautiful_3",
        "beautiful_4",
        "beautiful_5",
        "beautiful_6",
        "beautiful_7",
        "beautiful_8",
        "beautiful_9",
        "beautiful_10",
        "beautiful_11",
    ]

    static let technology: [String] =
    [
        "technology_1",
        "technology_3",
        "technology_4",
        "technology_5",
        "technology_6",
        "technology_7",
        "technology_8",
        "technology_9",
        "technology_10",
        "technology_11",
        "technology_12",
        "technology_13",
    ]
}
