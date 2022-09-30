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

    @State private var opacity: Double = 0
    @State private var isShowAlert = false
    @State private var isShowItemEdit = false
    @Binding var isShowitemDetail: Bool
    @Binding var tabIndex: Int

    var body: some View {

        ZStack {

            Color(.gray)
                .ignoresSafeArea()
                .opacity(0.3)

        RoundedRectangle (cornerRadius: 20)
                .foregroundColor(.black)
                .frame(width: 300, height: 500)
            .opacity(0.7)

                VStack(spacing: 10) {
                    Text(item[index].name)
                        .fontWeight(.black)
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 170, height: 170)
                        .foregroundColor(.yellow)

                    HStack {
                        Text("　アイテム情報")
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Button {
                            // NOTE: アイテム編集画面へ遷移するかをアラートで選択
                            self.isShowAlert = true
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
                            Text("アイテム情報を編集しますか？")
                        } // alert
                    } // HStack

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                    // NOTE: アイテムの情報が格納羅列されたカスタムViewです
                    SalesItemContents(sales:     item[index].sales,
                                      price:     item[index].price,
                                      inventory: item[index].inventory,
                                      createAt:  item[index].createAt,
                                      updateAt:  item[index].updateAt,
                                      tabIndex: $tabIndex
                    )

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                } // VStack
                .padding()
            } // ZStack
        // NOTE: opacityの設定によって遷移時のアニメーションを付与
        .opacity(self.opacity)
        .onAppear {
            withAnimation(.linear(duration: 0.3)) {
                self.opacity = 1.0
            }
        } // .onAppear
    } // body
} // View

struct SalesItemContents: View {

    let sales: Int
    let price: Int
    let inventory: Int
    let createAt: Date
    let updateAt: Date
    @Binding var tabIndex: Int

    var body: some View {


        VStack(alignment: .listRowSeparatorLeading, spacing: 8) {

            HStack {

                Text("在庫残り　:　　")
                Text("\(inventory) 個")

            } // HStack

            HStack {

                Text("価格　　　:　　")
                Text("\(price) 円")

            } // HStack

            HStack {

                Text("総売上　　:　　")
                Text("\(sales) 円")

            } // HStack

            // NOTE: こちらにはTimestampによる登録日が記述されます
            HStack {
                Text("登録日　　:　　")
                Text("2022. 8.30")

            } // HStack

            // NOTE: こちらにはTimestampによる最終更新日が記述されます
            HStack {
                Text("更新日　　:　　")
                Text("2022. 9.24")

            } // HStack
        } // VStack
        .fontWeight(.light)
        .foregroundColor(.white)

    } // body
} // View

struct SalesItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsItemDetail(item: [Item(tag: "Album", tagColor: "赤", name: "Album1",
                                    detail: "Album1のアイテム紹介テキストです。",
                                    photo: "", price: 1800, sales: 88000, inventory: 200,
                                    createAt: Date(), updateAt: Date())],
                        index: .constant(0),
                        isShowitemDetail: .constant(false),
                        tabIndex: .constant(2)
        )
    }
}
