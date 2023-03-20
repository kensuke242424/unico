//
//  SwiftUIView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/18.
//

import SwiftUI

struct SelectItemPhotoBackground: View {
    
    let photoImage: UIImage?
    let photoURL: URL?
    let height: CGFloat
    
    var body: some View {
        
        Color.clear
            .frame(width: getRect().width, height: height)
            .background(.ultraThinMaterial)
            .opacity(0.9)
            .background {
                if let photoImage = photoImage {
                    Image(uiImage: photoImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: getRect().width, height: height)
                        .clipped()
                        .blur(radius: 4, opaque: true)
                        .opacity(0.5)
                } else if let photoURL = photoURL {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white).opacity(0.1)
                            .frame(width: getRect().width, height: height)
                            .opacity(0.5)
                        
                        SDWebImageView(imageURL: photoURL,
                                          width: getRect().width,
                                          height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .blur(radius: 4, opaque: true)
                        .allowsHitTesting(false)
                    }
                    
                } else {
                    Image("background_1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: getRect().width, height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .overlay {
                LinearGradient(colors: [.clear, .black.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    .blur(radius: 5)
            }
    } // body
} // カスタムView

struct SelectItemPhotoBackground_Previews: PreviewProvider {
    static var previews: some View {
        SelectItemPhotoBackground(photoImage: nil, photoURL: nil, height: 250)
    }
}
