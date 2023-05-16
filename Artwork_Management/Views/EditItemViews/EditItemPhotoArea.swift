//
//  SelectItemPhotoArea.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/07.
//

import SwiftUI

struct EditItemPhotoArea: View {

    @Binding var showImageSheet: Bool
    let photoImage: UIImage?
    let photoURL: URL?

    var body: some View {

        Color.clear
            .frame(width: getRect().width, height: 350)
            .background(.ultraThinMaterial)
            .background {
                if let photoImage = photoImage {
                    Image(uiImage: photoImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: getRect().width, height: 350)
                        .clipped()
                } else if let photoURL = photoURL {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white).opacity(0.1)
                            .frame(width: getRect().width, height: 350)
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
                        .frame(width: getRect().width, height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .allowsHitTesting(false)
                        .shadow(radius: 4, x: 4, y: 4)
                    }

                } else {
                    Image("homePhoto_sample")
                        .resizable()
                        .scaledToFill()
                }
            }
            .overlay {
                LinearGradient(colors: [.clear, .black.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .blur(radius: 5)
            }

            .overlay {
                VStack {
                    Group {
                        if let photoImage = photoImage {
                            ShowItemUIImagePhoto(photoImage: photoImage, size: 270)
                        } else if let photoURL = photoURL {
                            ShowsItemAsyncImagePhoto(photoURL: photoURL, size: 270)
                        } else {
                            ShowItemUIImagePhoto(photoImage: nil, size: 270)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            // Todo: アイテム写真追加処理
                            showImageSheet.toggle()
                        } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .offset(x: 10, y: 10)
                        } // Button
                    } // .overlay(ボタン)
                } // VStack
            } // .overlay
    } // body
} // カスタムView

struct SelectItemPhotoArea_Previews: PreviewProvider {
    static var previews: some View {
        EditItemPhotoArea(showImageSheet: .constant(false), photoImage: nil, photoURL: nil)
    }
}
