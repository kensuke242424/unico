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

    // ジェネリクス「T」がFirestoreSerializableとDecodableに準拠している必要がある
    
    /// Firestoreのドキュメントから一つのモデルデータを取得するメソッド。
    /// - Parameter id: 取得対象データのドキュメントID
    /// - Returns: Firestoreから取得したオブジェクト
    static func fetch<T: FirestoreSerializable & Decodable>(withId id: String) async throws -> T {

        do {
            let teamDocument = try await Firestore.firestore()
                .collection(firestorePath().collectionPath)
                .document(id)
                .getDocument()

            let data = try teamDocument.data(as: T.self) // 取得データ
            return data
        } catch {
            print("ERROR: データ取得失敗")
            throw CustomError.fetch
        }
    }
}