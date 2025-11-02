//
//  FirebaseStorageManager.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/18.
//

import UIKit.UIImage
import FirebaseStorage

class FirebaseStorageManager {

    static func uploadImage( _ image: UIImage?, _ imageType: SaveStorageImageType) async throws -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            throw FirebaseStorageError.imageConversionFailed
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = imageType.storageFilePath
            let imageRef = reference.child(filePath)

            // 🔧 修正: Content-Typeを明示的に指定して画像として認識されるようにする
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            guard let url = try? await imageRef.downloadURL() else {
                throw FirebaseStorageError.urlRetrievalFailed
            }

            // 🔧 修正: URLから:443ポートを除去してiOSシミュレーターでの読み込み問題を解決
            let normalizedURL = normalizeFirebaseStorageURL(url)

            return (url: normalizedURL, filePath: filePath)
        } catch {
            throw FirebaseStorageError.uploadFailed(errorDescription: error.localizedDescription)
        }
    }

    /// Firebase StorageのURLから明示的なポート番号(:443)を除去するヘルパーメソッド
    /// iOSシミュレーターのHTTP/3プロトコル処理問題を回避するため
    private static func normalizeFirebaseStorageURL(_ url: URL) -> URL {
        var urlString = url.absoluteString
        // :443ポートを除去
        urlString = urlString.replacingOccurrences(of: ":443/", with: "/")
        return URL(string: urlString) ?? url
    }

    static func deleteImage(path: String?) async throws {
        guard let path = path else {
            throw FirebaseStorageError.invalidPath
        }

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        do {
            try await imageRef.delete()
        } catch {
            throw FirebaseStorageError.deleteFailed(errorDescription: error.localizedDescription)
        }
    }
}
