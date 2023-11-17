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
    case other(Error)

    var localizedDescription: String {
        switch self {
        case .dataNotFound:
            return "データが見つかりません。"
        case .decodeError:
            return "データのデコードに失敗しました。"
        case .setDataError:
            return "データのセットに失敗しました。"
        case .other(let error):
            return error.localizedDescription
        }
    }
}
