//
//  SalesItemDetailView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/30.
//

import SwiftUI

struct ShowsItemDetail: View {

    // NOTE: 親ViewからItem配列とインデックスを取得
    let item: [Item]
    @Binding var index: Int
    @Binding var isShowitemDetail: Bool

    @State private var opacity: Double = 0
    @State private var isShowAlert = false
    @State private var isShowItemEdit = false

    var body: some View {

        ZStack {

            Color(.gray)
                .ignoresSafeArea()
                .opacity(0.3)
            // NOTE: アイテム詳細の外側をタップすると、詳細画面を閉じます
                .onTapGesture {
                    withAnimation(.linear(duration: 0.2)) {
                        isShowitemDetail = false
                    }
                    print("onTapGesture_isShowitemDetail: \(isShowitemDetail)")
                } // onTapGesture

            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
                .frame(width: 300, height: 470)
                .opacity(0.7)

            if let showItem = item[index] {
                VStack(spacing: 10) {
                    Text(showItem.name)
                        .fontWeight(.black)
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                        .overlay {
                            Text("No Image.")
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(.white)
                        }

                    HStack {
                        Text("　アイテム情報")
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Button {
                            // NOTE: アイテム編集画面へ遷移するかをアラートで選択
                            isShowAlert.toggle()
                            print("isShowAlert: \(isShowAlert)")

                        } label: {
                            Image(systemName: "highlighter")
                                .foregroundColor(.yellow)
                        }
                        .alert("編集", isPresented: $isShowAlert) {

                            Button {
                                isShowAlert.toggle()
                                print("isShowAlert: \(isShowAlert)")
                            } label: {
                                Text("戻る")
                            }

                            Button {
                                isShowItemEdit.toggle()
                                print("isShowItemEdit: \(isShowItemEdit)")
                            } label: {
                                Text("はい")
                            }
                        } message: {
                            Text("アイテムデータを編集しますか？")
                        } // alert
                    } // HStack

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                    // NOTE: アイテムの情報が格納羅列されたカスタムViewです
                    ItemDetailContents(sales: showItem.sales,
                                       price: showItem.price,
                                       inventory: showItem.inventory,
                                       createAt: showItem.createAtTime,
                                       updateAt: showItem.updateAtTime
                    )

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                } // VStack

            } else {
                Text("アイテムデータが取得できませんでした")
            } // if let item[index]

        } // ZStack
        // NOTE: opacityの設定によって遷移時のアニメーションを付与
        .opacity(self.opacity)
        .onAppear {
            withAnimation(.linear(duration: 0.2)) {
                self.opacity = 1.0
            }
        } // .onAppear
    } // body
} // View

struct SalesItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsItemDetail(item: [Item(tag: "Album",
                                    tagColor: "赤",
                                    name: "Album1",
                                    detail: "Album1のアイテム紹介テキストです。",
                                    photo: "",
                                    price: 1800,
                                    sales: 88000,
                                    inventory: 200,
                                    createAtTime: Date(),
                                    updateAtTime: Date())],
                        index: .constant(0),
                        isShowitemDetail: .constant(false)
        )
    }
}
