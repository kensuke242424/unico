//
//  FirestoreDataType.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/18.
//

import Foundation

enum FirestorePathType {
    case teams
    case users
    case items(teamId: String)
    case tags(teamId: String)
    case members(teamId: String)
    case joins(userId: String)

    var collectionPath: String {
        switch self {
        case .teams:
            return "teams"
        case .users:
            return "users"
        case .items(let teamId):
            return "teams/\(teamId)/items"
        case .tags(let teamId):
            return "teams/\(teamId)/tags"
        case .members(teamId: let teamId):
            return "teams/\(teamId)/members"
        case .joins(userId: let userId):
            return "users/\(userId)/joins"
        }
    }
}
