//
//  FirestoreReferense.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/17.
//

import FirebaseFirestore

enum FirestoreReference {
    case teams
    case users
    case items(teamId: String)
    case tags(teamId: String)
    case members(teamId: String)
    case joins(userId: String)

    var collectionReference: CollectionReference {
        switch self {
        case .teams:
            return Firestore.firestore().collection("teams")
        case .users:
            return Firestore.firestore().collection("users")
        case .items(let teamId):
            return Firestore.firestore().collection("teams/\(teamId)/items")
        case .tags(let teamId):
            return Firestore.firestore().collection("teams/\(teamId)/tags")
        case .members(teamId: let teamId):
            return Firestore.firestore().collection("teams/\(teamId)/members")
        case .joins(userId: let userId):
            return Firestore.firestore().collection("users/\(userId)/joins")
        }
    }
}

enum FirestoreDataType {
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
