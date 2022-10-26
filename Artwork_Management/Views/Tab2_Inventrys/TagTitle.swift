//
//  TagTitle.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/17.
//

import SwiftUI

// ✅カスタムView: アイテムのタグタイトル
struct TagTitle: View {

    let title: String
    let font: Font

    var body: some View {

        HStack {
            Text("- \(title) -")
                .font(font.bold())
                .shadow(radius: 3, x: 4, y: 6)
                .padding(.horizontal)

            Spacer()
        }
    } // body
} // カスタムView

struct TagTitle_Previews: PreviewProvider {
    static var previews: some View {
        TagTitle(title: "アルバム", font: .title)
    }
}
