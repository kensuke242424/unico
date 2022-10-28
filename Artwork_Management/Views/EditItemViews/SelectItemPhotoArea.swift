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
            .blur(radius: 2.0)

            .overlay {
                LinearGradient(colors:
                                [Color.clear, Color.black], startPoint: .top, endPoint: .bottom)
                .blur(radius: 10)
            }

            .overlay {
                VStack {

                    ShowItemPhoto(photo: item?.photo ?? "", size: 270)
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                // Todo: アイテム写真追加処理
                            } label: {
                                Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .offset(x: 7, y: 7)
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
