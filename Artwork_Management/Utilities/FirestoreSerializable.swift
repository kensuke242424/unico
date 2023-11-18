//
//  FirestoreSerializable.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/16.
//

import FirebaseFirestore

protocol FirestoreSerializable {
    static func firestorePath() -> FirestorePath
}

// 各モデルデータ共通で使用されるロジック
extension FirestoreSerializable {

    static func fetch<T: FirestoreSerializable & Decodable>(path dataType: FirestoreDataType, docId id: String) async throws -> T {

        do {
            let document = try await Firestore.firestore()
                .collection(dataType.collectionPath)
                .document(id)
                .getDocument()

            let data = try document.data(as: T.self)
            return data

        } catch {
            if let firestoreError = error as? FirestoreError {
                throw firestoreError
            } else {
                throw FirestoreError.other(error)
            }
        }
    }

    static func setData<T: FirestoreSerializable & Codable>(path dataType: FirestoreDataType, docId id: String, data: T) async throws {

        do {
            try Firestore.firestore()
                .collection(firestorePath().collectionPath)
                .document(id)
                .setData(from: data, merge: true)

        } catch {
            throw FirestoreError.setDataError
        }
    }
}

// チームドキュメント専用で用いられるロジック
extension FirestoreSerializable {
    static func setMember(teamId: String, data: JoinMember) async throws {

        do {
            try FirestoreReference
                .members(teamId: teamId)
                .collectionReference
                .document(data.id)
                .setData(from: data) // データ保存
        } catch {
            throw FirestoreError.setDataError
        }
    }
}

// ユーザードキュメント専用で用いられるロジック
extension FirestoreSerializable {
    static func setJoinTeam(userId: String, data: JoinTeam) async throws {
        do {
            try FirestoreReference
                .joins(userId: userId)
                .collectionReference
                .document(data.id)
                .setData(from: data) // データ保存
        } catch {
            throw FirestoreError.setDataError
        }
    }
}

// 初期値サンプルデータの追加ロジック
extension FirestoreSerializable {

    static func setSampleItems(teamId: String) async {

        for item in sampleItems {

            var item = item
            item.teamID = teamId

            guard let itemId = item.id else { return }

            do {
                try Firestore.firestore()
                    .collection("teams")
                    .document(teamId)
                    .collection("items")
                    .document(itemId)
                    .setData(from: item) // データセット
            } catch {
                print("ERROR: サンプルアイテム\(item.name)の追加失敗")
            }
        }
    }

    static func setSampleTag(teamId: String) async {
        guard let sampleTagId = Tag.sampleTag.id else { return }

        do {
            try Firestore.firestore()
                .collection("teams")
                .document(teamId)
                .collection("tags")
                .document(sampleTagId)
                .setData(from: Tag.sampleTag) // データセット
        } catch {
            print("ERROR: サンプルタグの保存失敗")
        }
    }
}
