//
//  UserModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var address: String?
    var password: String?
    var iconURL: URL?
    var iconPath: String?
    var joins: [JoinTeam]
}

struct JoinTeam: Codable {
    var teamID: String
    var name: String
    var headerURL: URL?
    var headerPath: String?
    var settingColor: MemberColor
    @ServerTimestamp var logInTime: Timestamp?
}

struct ImageData: Codable {
    var url: URL?
    var path: String?
}

// ユーザそれぞれが個々に選ぶアプリ全体のカラー
enum MemberColor: CaseIterable, Codable {
    case red
    case blue
    case purple
    case green
    case yellow
    case brawn
    case pink
    case gray

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
