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
            _ = try await imageRef.putDataAsync(imageData)
            guard let url = try? await imageRef.downloadURL() else {
                throw FirebaseStorageError.urlRetrievalFailed
            }

            return (url: url, filePath: filePath)
        } catch {
            throw FirebaseStorageError.uploadFailed(errorDescription: error.localizedDescription)
        }
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
