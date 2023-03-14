//
//  PersonCircleIcon.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct PersonCircleIcon: View {
    let size: CGFloat
    var body: some View {
        
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(.white)
            .opacity(0.8)
    }
}

struct PersonCircleIcon_Previews: PreviewProvider {
    static var previews: some View {
        PersonCircleIcon(size: 100)
    }
}
