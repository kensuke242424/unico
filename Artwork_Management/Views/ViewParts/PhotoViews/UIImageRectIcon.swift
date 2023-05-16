//
//  UIImageRectIcon.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/13.
//

import SwiftUI

struct UIImageRectIcon: View {

    let photoImage: UIImage?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        
        Group {
            if let photoImage = photoImage {
                Image(uiImage: photoImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                
            } else {
                Rectangle()
                    .fill(.gray.gradient)
                    .frame(width: width, height: height)
                    .overlay {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black.opacity(0.7))
                    }
            }
        } // Group
    } // body
} // View

