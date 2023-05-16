//
//  AnimationExtension.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/05.
//

import SwiftUI

// 特定の条件下でのみリピートアニメーションを実行する
extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}
