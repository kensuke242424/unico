//
//  SelectItemPhotoArea.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/07.
//

import SwiftUI

struct SelectItemPhotoArea: View {

    let item: Item?

    var body: some View {

//        selectTagColor.color
        Color.customLightGray1
            .frame(width: UIScreen.main.bounds.width, height: 350)
            .blur(radius: 0)

            .overlay {
                LinearGradient(colors:
                                [Color.clear, Color.black], startPoint: .top, endPoint: .bottom)
                .blur(radius: 5)
            }

            .overlay {
                VStack {

                    ShowItemPhoto(photo: item?.photo ?? "", size: 270)
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                // Todo: アイテム写真追加処理
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
        SelectItemPhotoArea(item: TestItem().testItem)
    }
}
