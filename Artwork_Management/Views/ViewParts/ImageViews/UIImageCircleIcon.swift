//
//  UIImageCircleIcon.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/27.
//

import SwiftUI


struct UIImageCircleIcon: View {

    let photoImage: UIImage?
    let size: CGFloat

    var body: some View {

        Group {
            if let photoImage = photoImage {
                Image(uiImage: photoImage)
                    .resizable()
                    .scaledToFill()

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

struct UIImageCircleIcon_Previews: PreviewProvider {
    static var previews: some View {
        UIImageCircleIcon(photoImage: nil, size: 35)
    }
}
