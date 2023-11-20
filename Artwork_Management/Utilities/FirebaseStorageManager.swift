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
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "\(imageType.storageFilePath)/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        }
    }

    static func deleteImage(path: String?) async {
        guard let path = path else { return }

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        imageRef.delete { error in
            if let error = error {
                assertionFailure("ERROR: 画像削除に失敗。\(error.localizedDescription)")
            } else {
                print("画像削除に成功")
            }
        }
    }
}
