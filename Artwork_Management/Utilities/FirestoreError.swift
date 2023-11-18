//
//  FirestoreError.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/16.
//

enum FirestoreError: Error {
    case dataNotFound
    case decodeError
    case setDataError
    case fetchDocumentError
    case deleteError
    case other(Error)

    var localizedDescription: String {
        switch self {
        case .dataNotFound:
            return "データが見つかりません。"
        case .decodeError:
            return "データのデコードに失敗しました。"
        case .setDataError:
            return "データの保存に失敗しました。"
        case .fetchDocumentError:
            return "ドキュメントスナップショットの取得に失敗しました。"
        case .deleteError:
            return "データの削除に失敗しました"
        case .other(let error):
            return error.localizedDescription
        }
    }
}
