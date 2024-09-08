//
//  UIImageExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

extension UIImage {

    func resize(width imageWidth: CGFloat) -> UIImage? {

        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = self.size.height / self.size.width

        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: imageWidth * 2, height: imageWidth * Double(aspectScale) * 2)

        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        /// MEMO: 保存後の画像heightに少しだけ隙間ができるので、resizedSize.height + 1で対応してる
        self.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    func toBase64String() -> String? {

        guard let imageData = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        return imageData.base64EncodedString()

    }
}
