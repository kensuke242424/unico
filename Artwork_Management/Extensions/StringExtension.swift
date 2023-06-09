//
//  StringExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

extension String {

    func toImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: self) else { return nil }
        print("StringExtension_toImage()実行: \(imageData)")
        return UIImage(data: imageData)
    }
}
