//
//  InputFormTitle.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/06.
//

import SwiftUI

struct InputFormTitle: View {

    let title: String
    let isNeed: Bool

    var body: some View {

        HStack(spacing: 20) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(0.6)

            if isNeed {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 40, height: 20)
                    .foregroundColor(.gray)
                    .overlay {
                        Text("必須")
                            .font(.caption)
                            .foregroundColor(.black)
                    } // overlay
                    .opacity(0.6)
            } // if isNeed

        } // HStack

    } // body
} // View

struct InputFormTitle_Previews: PreviewProvider {
    static var previews: some View {
        InputFormTitle(title: "■タイトル", isNeed: true)
    }
}
