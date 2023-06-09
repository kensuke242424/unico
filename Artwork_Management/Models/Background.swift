//
//  Background.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/09.
//

import SwiftUI

enum TeamBackgroundContents: CaseIterable {
    case original, sample1, sample2, sample3, sample4

    var imageName: String {
        switch self {
        case .original:
            return ""
        case .sample1:
            return "background_1"
        case .sample2:
            return "background_2"
        case .sample3:
            return "background_3"
        case .sample4:
            return "background_4"
        }
    }
}

struct CoolBackground {

    static let cool_1 = Image("cool_1")
    static let cool_2 = Image("cool_2")
    static let cool_3 = Image("cool_3")
    static let cool_4 = Image("cool_4")
    static let cool_5 = Image("cool_5")
    static let cool_6 = Image("cool_6")
    static let cool_7 = Image("cool_7")
    static let cool_8 = Image("cool_8")
    static let cool_9 = Image("cool_9")
}

struct ArtBackground {

    static let art_1 = Image("art_1")
    static let art_2 = Image("art_2")
    static let art_3 = Image("art_3")
    static let art_4 = Image("art_4")
    static let art_5 = Image("art_5")
    static let art_6 = Image("art_6")
    static let art_7 = Image("art_7")
    static let art_8 = Image("art_8")
    static let art_9 = Image("art_9")
    static let art_10 = Image("art_10")
}

struct CafeBackground {

    static let cafe_1 = Image("cafe_1")
    static let cafe_2 = Image("cafe_2")
    static let cafe_3 = Image("cafe_3")
    static let cafe_4 = Image("cafe_4")
    static let cafe_5 = Image("cafe_5")
    static let cafe_6 = Image("cafe_6")
    static let cafe_7 = Image("cafe_7")
    static let cafe_8 = Image("cafe_8")
    static let cafe_9 = Image("cafe_9")
    static let cafe_10 = Image("cafe_10")
}

struct CuteBackground {

    static let cute_1 = Image("cute_1")
    static let cute_2 = Image("cute_2")
    static let cute_3 = Image("cute_3")
    static let cute_4 = Image("cute_4")
    static let cute_5 = Image("cute_5")
    static let cute_6 = Image("cute_6")
    static let cute_7 = Image("cute_7")
    static let cute_8 = Image("cute_8")
    static let cute_9 = Image("cute_9")
    static let cute_10 = Image("cute_10")
    static let cute_11 = Image("cute_11")
    static let cute_12 = Image("cute_12")
}

struct DarkBackground {

    static let dark_1 = Image("dark_1")
    static let dark_2 = Image("dark_2")
    static let dark_3 = Image("dark_3")
    static let dark_4 = Image("dark_4")
    static let dark_5 = Image("dark_5")
    static let dark_6 = Image("dark_6")
    static let dark_7 = Image("dark_7")
    static let dark_8 = Image("dark_8")
    static let dark_9 = Image("dark_9")
    static let dark_10 = Image("dark_10")
}

struct MusicBackground {

    static let music_1 = Image("music_1")
    static let music_2 = Image("music_2")
    static let music_3 = Image("music_3")
    static let music_4 = Image("music_4")
    static let music_5 = Image("music_5")
    static let music_6 = Image("music_6")
    static let music_7 = Image("music_7")
    static let music_8 = Image("music_8")
    static let music_9 = Image("music_9")
    static let music_10 = Image("music_10")
    static let music_11 = Image("music_11")
    static let music_12 = Image("music_12")
    static let music_13 = Image("music_13")
    static let music_14 = Image("music_14")
    static let music_15 = Image("music_15")
}

struct TechnologyBackground {

    static let technology_1 = Image("technology_1")
    static let technology_2 = Image("technology_2")
    static let technology_3 = Image("technology_3")
    static let technology_4 = Image("technology_4")
    static let technology_5 = Image("technology_5")
    static let technology_6 = Image("technology_6")
    static let technology_7 = Image("technology_7")
    static let technology_8 = Image("technology_8")
    static let technology_9 = Image("technology_9")
    static let technology_10 = Image("technology_10")
    static let technology_11 = Image("technology_11")
}
