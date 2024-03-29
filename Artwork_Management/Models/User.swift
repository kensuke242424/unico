//
//  UserModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: FirestoreSerializable, Identifiable, Codable, Equatable {

    var id: String
    var createTime = Date()
    var name: String
    var address: String?
    var password: String?
    var iconURL: URL?
    var iconPath: String?
    var userColor: ThemeColor
    var joinsId: [String]
    var myBackgrounds: [Background] = []
    var favorites: [String] = []
    var lastLogIn: String?

    static func firestorePath() -> FirestorePath { .users }
}


struct JoinTeam: FirestoreSerializable, Codable, Hashable {

    var id: String
    var name: String
    var iconURL: URL?
    var currentBackground: Background?
    var myBackgrounds: [Background] = []
    var homeEdits = HomeEditData(nowTime: NowTimeParts(),
                                     teamNews: TeamNewsParts())
    var approved: Bool?

    static func firestorePath() -> FirestorePath { .users }
}

/// Homeの各パーツ設定をまとめたデータモデル
struct HomeEditData: Codable, Hashable {
    var nowTime: NowTimeParts
    var teamNews: TeamNewsParts
}

struct ImageData: Codable {
    var url: URL?
    var path: String?
}

// ユーザーそれぞれが個々に選ぶアプリ全体のテーマカラー
enum ThemeColor: CaseIterable, Codable {
    case red
    case blue
    case purple
    case green
    case yellow
    case brawn
    case pink
    case gray

    var light: Color {
        switch self {
        case .red: return .userRed1
        case .blue: return .userBlue1
        case .purple: return .userPurple1
        case .green: return .userGreen1
        case .yellow: return .userYellow1
        case .brawn: return .userBrawn1
        case .pink: return .userPink1
        case .gray: return .userGray1
        }
    }

    var medium: Color {
        switch self {
        case .red: return .userRed1
        case .blue: return .userBlue1
        case .purple: return .userPurple1
        case .green: return .userGreen1
        case .yellow: return .userYellow1
        case .brawn: return .userBrawn1
        case .pink: return .userPink1
        case .gray: return .userGray1
        }
    }

    var dark: Color {
        switch self {
        case .red: return .userRed1
        case .blue: return .userBlue1
        case .purple: return .userPurple1
        case .green: return .userGreen1
        case .yellow: return .userYellow1
        case .brawn: return .userBrawn1
        case .pink: return .userPink1
        case .gray: return .userGray1
        }
    }

    var color1: Color {
        switch self {
        case .red: return .userRed1
        case .blue: return .userBlue1
        case .purple: return .userPurple1
        case .green: return .userGreen1
        case .yellow: return .userYellow1
        case .brawn: return .userBrawn1
        case .pink: return .userPink1
        case .gray: return .userGray1
        }
    }
    var color2: Color {
        switch self {
        case .red: return .userRed2
        case .blue: return .userBlue2
        case .purple: return .userPurple2
        case .green: return .userGreen2
        case .yellow: return .userYellow2
        case .brawn: return .userBrawn2
        case .pink: return .userPink2
        case .gray: return .userGray2
        }
    }
    var color3: Color {
        switch self {
        case .red: return .userRed3
        case .blue: return .userBlue3
        case .purple: return .userPurple3
        case .green: return .userGreen3
        case .yellow: return .userYellow3
        case .brawn: return .userBrawn3
        case .pink: return .userPink3
        case .gray: return .userGray3
        }
    }
    var color4: Color {
        switch self {
        case .red: return .userRed4
        case .blue: return .userBlue4
        case .purple: return .userPurple4
        case .green: return .userGreen4
        case .yellow: return .userYellow4
        case .brawn: return .userBrawn4
        case .pink: return .userPink4
        case .gray: return .userGray4
        }
    }
    var colorAccent: Color {
        switch self {
        case .red: return .userRedAccent
        case .blue: return .userBlueAccent
        case .purple: return .userPurpleAccent
        case .green: return .userGreenAccent
        case .yellow: return .userYellowAccent
        case .brawn: return .userBrawnAccent
        case .pink: return .userPinkAccent
        case .gray: return .userGrayAccent
        }
    }
}
