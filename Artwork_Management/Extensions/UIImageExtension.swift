//
//  UIImageExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

extension UIImage {

    func toBase64String() -> String? {

        guard let imageData = self.jpegData(compressionQuality: 1.0) else {
            print("Error: self.jpegData(compressionQuality: 1.0)")
            return nil
        }
        print("UIImageExtension_toBase64String()実行: \(imageData)")
        return imageData.base64EncodedString()

    }
}
