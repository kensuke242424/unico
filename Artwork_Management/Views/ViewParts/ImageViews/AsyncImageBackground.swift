//
//  AsyncImageBackground.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/14.
//

import SwiftUI

struct AsyncImageBackground: View {
    
    let photoURL: URL?
    
    var body: some View {
        
        
        Group {
            GeometryReader { proxy in
                if let photoURL = photoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                        
                    } placeholder: {
                        ProgressView()
                            .background {
                                Circle()
                                    .foregroundColor(.black)
                                    .opacity(0.1)
                            }
                    }
                } else {
                    Image("background_1")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.white.opacity(0.7))
                }
            } // Geometry
            .ignoresSafeArea()
        }
    }
}

struct AsyncImageBackground_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageBackground(photoURL: nil)
    }
}
