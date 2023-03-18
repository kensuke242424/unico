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
            .background {
                if let photoImage = photoImage {
                    Image(uiImage: photoImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: getRect().width, height: height)
                        .clipped()
                } else if let photoURL = photoURL {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white).opacity(0.1)
                            .frame(width: getRect().width, height: height)
                        AsyncImage(url: photoURL) { itemImage in
                            itemImage
                                .resizable()
                                .scaledToFill()
                            
                        } placeholder: {
                            ZStack {
                                ProgressView()
                                Color.black.opacity(0.2)
                            }
                        }
                        .frame(width: getRect().width, height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .allowsHitTesting(false)
                        .shadow(radius: 4, x: 4, y: 4)
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
