//
//  SDWebImageBackground.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/07/11.
//

import SwiftUI
import SDWebImageSwiftUI

struct SDWebImageBackground: View {

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
            Text("No Image.")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(0.7)
        }
    }
}
