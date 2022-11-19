//
//  CircleIcon.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/29.
//

import SwiftUI

struct CircleIcon: View {

    let photoURL: URL?
    let size: CGFloat

    var body: some View {

        Group {
            if let photoURL = photoURL {
                AsyncImage(url: photoURL) { iconImage in
                    iconImage
                        .resizable()
                        .scaledToFill()

                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .shadow(radius: 2, x: 1, y: 2)
        .shadow(radius: 2, x: 1, y: 2)

    }
}

struct CircleIcon_Previews: PreviewProvider {
    static var previews: some View {
        CircleIcon(photoURL: nil, size: 35)
    }
}
