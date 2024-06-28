//
//  FirestoreError.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/16.
//

enum FirestoreError: Error {
    case dataNotFound(String)
    case decodeError(Error)
    case setDataError(Error)
    case fetchDocumentError(Error)
    case deleteError(Error)
    case other(Error)

    var localizedDescription: String {
        switch self {
        case .dataNotFound(let id):
            return "データが見つかりません。ID: \(id)"
        case .decodeError(let error):
            return "データのデコードに失敗しました。エラー: \(error.localizedDescription)"
        case .setDataError(let error):
            return "データの保存に失敗しました。エラー: \(error.localizedDescription)"
        case .fetchDocumentError(let error):
            return "ドキュメントスナップショットの取得に失敗しました。エラー: \(error.localizedDescription)"
        case .deleteError(let error):
            return "データの削除に失敗しました。エラー: \(error.localizedDescription)"
        case .other(let error):
            return error.localizedDescription
        }
    }
}
