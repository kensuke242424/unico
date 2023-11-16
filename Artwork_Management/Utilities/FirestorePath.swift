//
//  FirestorePath.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/16.
//

import FirebaseFirestore

enum FirestorePath {
    case teams
    case users
    case items(teamId: String)

    var referense: DocumentReference? {
        return nil
    }

    var collectionPath: String {
        switch self {
        case .teams:
            return "teams"
        case .users:
            return "users"
        case .items(let teamId):
            return "teams/\(teamId)/items"
        }
    }
}
