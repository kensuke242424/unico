//
//  FirebaseStorageError.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/22.
//

enum FirebaseStorageError: Error {
    case imageConversionFailed
    case uploadFailed(errorDescription: String)
    case urlRetrievalFailed
    case deleteFailed(errorDescription: String)
    case invalidPath

    var localizedDescription: String {
            switch self {
            case .imageConversionFailed:
                return "画像の変換に失敗しました。"
            case .uploadFailed(let errorDescription):
                return "画像のアップロードに失敗しました: \(errorDescription)"
            case .urlRetrievalFailed:
                return "画像URLの取得に失敗しました。"
            case .deleteFailed(let errorDescription):
                return "画像の削除に失敗しました: \(errorDescription)"
            case .invalidPath:
                return "無効なパスが指定されました。"
            }
        }
}
