//
//  GetDocumentIds.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/15.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

/// チームに所属しているメンバーのメンバーIdを取得するメソッド。
public func getMembersId(teamId: String) async throws -> [String]? {
    var db: Firestore? = Firestore.firestore()

    /// membersサブコレクションのスナップショットを取得
    let membersSnapshot = try await db?
        .collection("teams")
        .document(teamId)
        .collection("members")
        .getDocuments()

    // メンバー全員のidを取得
    return membersSnapshot?.documents.compactMap {$0.documentID}
}

/// ユーザーが所属しているチームのチームIdを取得するメソッド。
public func getJoinsId() async throws -> [String]? {
    guard let uid = Auth.auth().currentUser?.uid else {
        assertionFailure("uidが存在しません")
        return nil
    }
    var db: Firestore? = Firestore.firestore()

    /// joinsサブコレクションのスナップショットを取得
    let joinsSnapshot = try await db?
        .collection("users")
        .document(uid)
        .collection("joins")
        .getDocuments()

    // 所属チームのidを取得
    return joinsSnapshot?.documents.compactMap {$0.documentID}
}
