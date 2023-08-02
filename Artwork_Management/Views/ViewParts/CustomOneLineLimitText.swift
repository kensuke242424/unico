//
//  CustomOneLineLimitText.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/01.
//

import SwiftUI

/// 一行内にテキストを収めるカスタムテキスト。
/// 指定リミット数より文字数が多い時、横型スクロールが付与される。
struct CustomOneLineLimitText: View {
    let text: String
    let limit: Int
    var body: some View {
        if text.count > limit {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .lineLimit(1)
            }
            /// スクロール時の引っ掛かりを無くす
            .introspectScrollView { scrollView in
                 scrollView.isDirectionalLockEnabled = true
                 scrollView.bounces = false
            }
        } else {
            Text(text)
                .lineLimit(1)
        }
    }
}
