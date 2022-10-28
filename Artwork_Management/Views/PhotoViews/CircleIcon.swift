//
//  CircleIcon.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/29.
//

import SwiftUI

struct CircleIcon: View {

    let photo: String
    let size: CGFloat

    var body: some View {

        Image(photo)
            .resizable().scaledToFit()
            .frame(width: size)
            .clipShape(Circle())
            .shadow(radius: 2, x: 1, y: 2)
            .padding(.leading)
    }
}

struct CircleIcon_Previews: PreviewProvider {
    static var previews: some View {
        CircleIcon(photo: "cloth_sample1", size: 35)
    }
}
