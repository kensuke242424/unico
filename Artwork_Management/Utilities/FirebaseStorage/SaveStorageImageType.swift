//
//  SaveStorageImageType.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/20.
//

import Foundation.NSDate

enum SaveStorageImageType {
    case user(userId: String)
    case team(teamId: String)
    case item(teamId: String)
    case myBackground(userId: String)

    var storageFilePath: String {
        switch self {
        case .user(let userId):
            return "users/\(userId)\(Date())"
        case .team(let teamId):
            return "teams/\(teamId)\(Date())"
        case .item(let teamId):
            return "teams/\(teamId)/items\(Date())"
        case .myBackground(let userId):
            return "users/\(userId)/myBackgrounds\(Date())"
        }
    }
}
