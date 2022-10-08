//
//  SalesItemDetailView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/30.
//

import SwiftUI

struct ShowsItemDetail: View {

    @StateObject var itemVM: ItemViewModel

    // NOTE: 親Viewから選択Itemとインデックスを取得
    //       Itemはnilを許容し、nilだった場合「データが取得できませんでした」と表示
    let item: Item?
    let itemIndex: Int
    @Binding var isShowitemDetail: Bool

    @State private var disabledButton = true
    @State private var opacity: Double = 0
    @State private var isShowAlert = false
    @State private var isPlesentedUpdateItem = false
    @State private var isPlesentedErrorInfomation = false

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

            if let showItem = item {

            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
                .frame(width: 300, height: 470)
                .opacity(0.7)

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
                                .foregroundColor(disabledButton ? .gray : .yellow)
                        }
                        .disabled(disabledButton)
                        .alert("編集", isPresented: $isShowAlert) {

                            Button {
                                isShowAlert.toggle()
                                print("isShowAlert: \(isShowAlert)")
                            } label: {
                                Text("戻る")
                            }

                            Button {
                                isPlesentedUpdateItem.toggle()
                                print("isShowItemEdit: \(isPlesentedUpdateItem)")
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
                                       createAt: showItem.createTime,
                                       updateAt: showItem.updateTime
                    )

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                } // VStack(item != nil の時)

            } else {

                VStack {

                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.black)
                        .frame(width: 300, height: 470)
                        .opacity(0.7)
                        .overlay {
                            Text("アイテムデータが取得できません")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .overlay(alignment: .bottomTrailing) {

                            Button {
                                // Todo: エラー報告インフォメーションへ遷移
                                isPlesentedErrorInfomation.toggle()
                            } label: {
                                Text("エラーを報告する>>")
                                    .padding()
                            } // Button
                        } // overlay
                } // VStack(item == nil の時)

            } // if let item

        } // ZStack(全体)
        .opacity(self.opacity)

        .sheet(isPresented: $isPlesentedUpdateItem) {

            // NOTE: itemがnilでない場合のみボタンを有効にしているため、ボタンアクション時には値を強制アンラップしています。
            UpdateItemView(itemVM: itemVM,
                           isPresentedUpdateItem: $isPlesentedUpdateItem,
                           itemIndex: itemIndex,
                           updateItem: item!)
        } // sheet(アイテム更新シート)

        .onAppear {

            // NOTE: itemに値が存在した場合、アイテム編集ボタンを有効化
            if item != nil {
                self.disabledButton.toggle()
            }

            // NOTE: opacityの動的な値の変化を使ったフェードアニメーション
            withAnimation(.linear(duration: 0.2)) {
                self.opacity = 1.0
            }

        } // .onAppear

    } // body
} // View

struct SalesItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsItemDetail(itemVM: ItemViewModel(),
                        item: Item(tag: "Album",
                                   tagColor: "赤",
                                   name: "Album1",
                                   detail: "Album1のアイテム紹介テキストです。",
                                   photo: "",
                                   price: 1800, sales: 88000,
                                   inventory: 200,
                                   createTime: Date(),
                                   updateTime: Date()),
                        itemIndex: 0,
                        isShowitemDetail: .constant(false)
        )
    }
}
