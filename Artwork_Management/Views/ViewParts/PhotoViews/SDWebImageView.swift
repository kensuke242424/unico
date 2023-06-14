//
//  NewItemSDWebImage.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/18.
//

import SwiftUI
import SDWebImageSwiftUI

struct SDWebImageView: View {
    
    let imageURL: URL?
    let width   : CGFloat
    let height  : CGFloat
    
    var body: some View {
        if let imageURL = imageURL {
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white).opacity(0.01)
                    .frame(width: width, height: height)
                WebImage(url: imageURL)
                    .resizable()
                    .placeholder {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.black.opacity(0.4))
                                .frame(width: width, height: height)
                            ProgressView()
                        }
                    }
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .shadow(radius: 1, x: 2, y: 2)
                    .shadow(radius: 1, x: 2, y: 2)
                    .animation(.easeInOut(duration: 0.5), value: imageURL)
                    .transition(.fade(duration: 0.5))
                    .allowsHitTesting(false)
            }
            
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.gray)
                .frame(width: width, height: height)
                .shadow(radius: 1, x: 2, y: 2)
                .shadow(radius: 1, x: 2, y: 2)
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


struct NewItemSDWebImage_Previews: PreviewProvider {
    
    static var contentHeight: CGFloat = 220
    
    static var previews: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                Spacer()
                HStack(spacing: -25) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                        .frame(width: size.width / 2 - 15, height: contentHeight * 0.8)
                        .overlay(Text("アイテム詳細"))
                        .zIndex(1)
                    
                    SDWebImageView(imageURL: nil,
                                      width: size.width / 2 - 15,
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
