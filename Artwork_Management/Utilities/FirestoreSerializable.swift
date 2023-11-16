//
//  FirestoreSerializable.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/16.
//

import FirebaseFirestore

protocol FirestoreSerializable {
    var id: String { get }
    static func firestorePath() -> FirestorePath
}

extension FirestoreSerializable {

    static func fetch<T: FirestoreSerializable & Decodable>(withId id: String) async throws -> T {

        do {
            let teamDocument = try await Firestore.firestore()
                .collection(firestorePath().collectionPath)
                .document(id)
                .getDocument()

            let data = try teamDocument.data(as: T.self)
            return data
        } catch {
            print("ERROR: データ取得失敗")
            throw CustomError.fetch
        }
    }
}
