//
//  CircleIcon.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/29.
//

import SwiftUI

struct CircleIcon: View {

    let photo: UIImage?
    let size: CGFloat

    var body: some View {

        Group {
            if let photo = photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
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
        CircleIcon(photo: UIImage(), size: 35)
    }
}
