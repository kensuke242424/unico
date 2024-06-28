//
//  FirestorePath.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/16.
//

enum FirestorePath {
    case teams
    case users
    case items
    case tags

    var collectionPath: String {
        switch self {
        case .teams:
            return "teams"
        case .users:
            return "users"
        case .items:
            return "teams"
        case .tags:
            return "tags"
        }
    }
}
