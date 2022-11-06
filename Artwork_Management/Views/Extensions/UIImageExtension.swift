//
//  UIImageExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

extension UIImage {
    func toString() -> String? {

        // 指定された画像を含む PNG 形式のデータオブジェクトを返す
        let pngData = self.pngData()

        // Base-64でエンコードされた文字列を返す
        // 行の最大長を64文字に設定し、それ以降は行末を挿入
        return pngData?.base64EncodedString(options: .lineLength64Characters)
    }
}
