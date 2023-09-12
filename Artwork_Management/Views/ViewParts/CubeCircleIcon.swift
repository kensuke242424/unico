//
//  CubeCircleIcon.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct CubeCircleIcon: View {
    
    let size: CGFloat
    
    var body: some View {
        
        Circle()
            .foregroundColor(.userGray2)
            .opacity(0.8)
            .frame(width: size, height: size)
            .shadow(radius: 2, x: 1, y: 2)
            .shadow(radius: 2, x: 1, y: 2)
            .overlay {
                Image(systemName: "cube.transparent.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size / 2)
                    .foregroundColor(.white)
            }
    }
}

struct CubeCircleIcon_Previews: PreviewProvider {
    static var previews: some View {
        CubeCircleIcon(size: 80)
    }
}
