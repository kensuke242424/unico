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

    static func fetch<T: FirestoreSerializable & Decodable>(_ pathType: FirestorePathType, docId id: String) async throws -> T {

        do {
            let document = try await Firestore.firestore()
                .collection(pathType.collectionPath)
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

    static func fetchDatas<T: FirestoreSerializable & Decodable>(_ pathType: FirestorePathType) async throws -> [T] {

        do {
            let snapshot = try await Firestore.firestore()
                .collection(pathType.collectionPath)
                .getDocuments()

            let datas = try snapshot.documents.compactMap { document in
                let data = try document.data(as: T.self)
                return data
            }

            return datas

        } catch {
            if let firestoreError = error as? FirestoreError {
                throw firestoreError
            } else {
                throw FirestoreError.other(error)
            }
        }
    }

    static func setData<T: FirestoreSerializable & Codable>(_ pathType: FirestorePathType, docId id: String, data: T) async throws {

        do {
            try Firestore.firestore()
                .collection(pathType.collectionPath)
                .document(id)
                .setData(from: data, merge: true)

        } catch {
            if let firestoreError = error as? FirestoreError {
                throw firestoreError
            } else {
                throw FirestoreError.other(error)
            }
        }
    }

    static func getDocument(_ pathType: FirestorePathType, docId: String) -> DocumentReference {
        do {
            let documentRef = Firestore.firestore()
                .collection(pathType.collectionPath)
                .document(docId)

            return documentRef
        }
    }

    static func getDocuments(_ pathType: FirestorePathType) async throws -> QuerySnapshot {

        do {
            let snapShot = try await Firestore.firestore()
                .collection(pathType.collectionPath)
                .getDocuments()

            return snapShot

        } catch {
            if let firestoreError = error as? FirestoreError {
                throw firestoreError
            } else {
                throw FirestoreError.other(error)
            }
        }
    }

    static func getMatchingDocuments<T>(_ pathType: FirestorePathType, field: String, equalTo: T) async throws -> QuerySnapshot? {

        do {
            let snapShot = try await Firestore.firestore()
                .collection(pathType.collectionPath)
                .whereField(field, isEqualTo: equalTo)
                .getDocuments()

            return snapShot

        } catch {
            if let firestoreError = error as? FirestoreError {
                throw firestoreError
            } else {
                throw FirestoreError.other(error)
            }
        }
    }

    static func deleteDocument(_ pathType: FirestorePathType, docId: String) async throws {
        do {
            try await Firestore.firestore()
                .collection(pathType.collectionPath)
                .document(docId)
                .delete() // 削除
        } catch {
            if let firestoreError = error as? FirestoreError {
                throw firestoreError
            } else {
                throw FirestoreError.other(error)
            }
        }
    }

    static func deleteDocuments(_ pathType: FirestorePathType) async throws {
        do {
            let snapshot = try await Firestore.firestore()
                .collection(pathType.collectionPath)
                .getDocuments()

            for document in snapshot.documents {
                try await document.reference.delete() // ドキュメント削除
            }

        } catch {
            if let firestoreError = error as? FirestoreError {
                throw firestoreError
            } else {
                throw FirestoreError.other(error)
            }
        }
    }
}

// Log操作専用のロジック
extension FirestoreSerializable {

    /// 対象ログをメンバー全員が既読済みかどうかを検索判定するメソッド。
    static func isLogReadByAllMembers(log: Log, teamId: String, members: [JoinMember]) async throws -> Bool {

        var unreadMemberLogRefs: [QuerySnapshot] = []

        for member in members {
            let query = Firestore.firestore()
                .collection("teams")
                .document(teamId)
                .collection("members")
                .document(member.id)
                .collection("logs")
                .whereField("id", isEqualTo: log.id)
                .whereField("read", isEqualTo: false) // falseなら未読

            do {
                let querySnapshot = try await query.getDocuments()
                if !querySnapshot.isEmpty {
                    unreadMemberLogRefs.append(querySnapshot)
                }
            } catch {
                if let firestoreError = error as? FirestoreError {
                    throw firestoreError
                } else {
                    throw FirestoreError.other(error)
                }
            }
        }

        return unreadMemberLogRefs.isEmpty
    }
}

// 初期値サンプルデータの追加ロジック
extension FirestoreSerializable {

    static func setSampleItems(teamId: String) async {

        for item in sampleItems {

            var item = item
            item.teamID = teamId

            do {
                try Firestore.firestore()
                    .collection("teams")
                    .document(teamId)
                    .collection("items")
                    .document(item.id)
                    .setData(from: item) // データセット
            } catch {
                print("ERROR: サンプルアイテム\(item.name)の追加失敗")
            }
        }
    }

    static func setSampleTag(teamId: String) async {

        do {
            try Firestore.firestore()
                .collection("teams")
                .document(teamId)
                .collection("tags")
                .document(Tag.sampleTag.id)
                .setData(from: Tag.sampleTag) // データセット
        } catch {
            print("ERROR: サンプルタグの保存失敗")
        }
    }
}


