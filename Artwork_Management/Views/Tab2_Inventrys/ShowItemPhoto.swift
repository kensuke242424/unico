//
//  ShowItemPhoto.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/28.
//

import SwiftUI

struct ShowItemPhoto: View {

    let photo: String
    let size: CGFloat

    var body: some View {
        if photo != "" {
            Image(photo)
                .resizable().scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 4, x: 5, y: 5)

        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray)
                .frame(width: size, height: size)
                .shadow(radius: 4, x: 5, y: 5)
                .overlay {
                    Text("No Image.")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(0.5)
                }
        }
    }
}
