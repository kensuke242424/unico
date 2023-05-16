//
//  SDWebImageCircleIcon.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct SDWebImageCircleIcon: View {
    
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
                    .clipShape(Circle())
                    .shadow(radius: 1, x: 2, y: 2)
                    .shadow(radius: 1, x: 2, y: 2)
                    .allowsHitTesting(false)
            }
            
        } else {
            Circle()
                .foregroundColor(.userGray2)
                .frame(width: width, height: height)
                .shadow(radius: 1, x: 1, y: 1)
                .overlay {
                    VStack(spacing: 20) {
                        Image(systemName: "cube.transparent.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.55)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
        }
    }
}

struct SDWebImageCircleIcon_Previews: PreviewProvider {
    static var previews: some View {
        SDWebImageCircleIcon(imageURL: nil,
                             width   : 50,
                             height  : 50)
    }
}
