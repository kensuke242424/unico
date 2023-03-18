//
//  SwiftUIView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/18.
//

import SwiftUI

struct NewItemUIImage: View {

    let image: UIImage?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        if let image = image {
            
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.white).opacity(0.01)
                    .frame(width: width, height: height)
                Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .allowsHitTesting(false)
            }

        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.gray)
                .frame(width: width, height: height)
                .overlay {
                    VStack(spacing: 20) {
                        Image(systemName: "cube.transparent.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .foregroundColor(.white)
                        Text("No Image.")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(0.7)
                    }
                }
        }
    }
}

struct NewItemUIImage_Previews: PreviewProvider {
    
    static var contentHeight: CGFloat = 220
    
    static var previews: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                Spacer()
                HStack(spacing: -25) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                        .frame(width: size.width / 2, height: contentHeight * 0.8)
                        .overlay(Text("アイテム詳細"))
                        .zIndex(1)
                    
                    NewItemUIImage(image: nil,
                                   width: size.width / 2,
                                   height: size.height)
                }
                Spacer()
            }
            .frame(width: size.width)
            .ignoresSafeArea()
        }
        .frame(height: contentHeight)
    }
}
