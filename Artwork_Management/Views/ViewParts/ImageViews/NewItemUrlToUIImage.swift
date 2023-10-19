//
//  NewItemUrlToUIImage.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/18.
//

import SwiftUI

struct NewItemUrlToUIImage: View {

    let imageURL: URL?
    @State var uiImage: UIImage?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack {
            if let uiImage = uiImage {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.white).opacity(0.01)
                        .frame(width: width, height: height)
                    Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .allowsHitTesting(false)
                }

            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.gradient)
                    .frame(width: width, height: height)
                    .overlay {
                        VStack(spacing: 20) {
                            Image(systemName: "cube.transparent.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .foregroundColor(.white)
                                .opacity(0.6)
                            Text("No Image.")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(0.7)
                        }
                    }
            }
        }
        .onAppear {
//            uiImage = downsample(imageAt: imageURL, to: CGSize(width: width, height: height))
            getUIImageByUserUrl(url: imageURL)
        }
    }
    
    private func getUIImageByUserUrl(url: URL?) {
        guard let url else { return }
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                uiImage = UIImage(data: data)
                print("userIconのurl->UIImage成功")
                
            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
    }
    
    func downsample(imageAt imageURL: URL?,
                    to pointSize: CGSize,
                    scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        
        guard let imageURL else { return nil }

        // Create an CGImageSource that represent an image
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return nil
        }
        
        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        // Return the downsampled image as UIImage
        return UIImage(cgImage: downsampledImage)
    }
}

struct NewItemUrlToUIImage_Previews: PreviewProvider {
    
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
                    
                    NewItemUrlToUIImage(imageURL: nil,
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
