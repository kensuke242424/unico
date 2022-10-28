//
//  SalesItemDetailView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/30.
//

import SwiftUI

struct ShowsItemDetail: View {

    @StateObject var itemVM: ItemViewModel

    let item: Item
    let itemIndex: Int
    @Binding var isShowItemDetail: Bool
    @Binding var isPresentedEditItem: Bool

    struct InputItemDetail {
        var opacity: Double = 0
        var isShowAlert: Bool = false
    }

    @State private var inputDetail: InputItemDetail = InputItemDetail()

    var body: some View {

        ZStack {

            Color(.gray)
                .ignoresSafeArea()
                .opacity(0.4)
                .onTapGesture { isShowItemDetail = false }

            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
                .frame(width: 300, height: 470)
                .opacity(0.9)
                .overlay {
                    Color.customDarkBlue2
                        .opacity(0.5)
                        .blur(radius: 20)
                }

                .overlay {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            Text(item.name)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .tracking(1)
                                .lineLimit(1)

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
                                    inputDetail.isShowAlert.toggle()
                                    print("isShowAlert: \(inputDetail.isShowAlert)")

                                } label: {
                                    Image(systemName: "highlighter")
                                        .foregroundColor(.yellow)
                                }
                                .alert("編集", isPresented: $inputDetail.isShowAlert) {

                                    Button {
                                        inputDetail.isShowAlert.toggle()
                                        print("isShowAlert: \(inputDetail.isShowAlert)")
                                    } label: {
                                        Text("戻る")
                                    }

                                    Button {
                                        isPresentedEditItem.toggle()
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
                            ItemDetailContents(sales: item.sales,
                                               price: item.price,
                                               inventory: item.inventory,
                                               createAt: item.createTime,
                                               updateAt: item.updateTime
                            )

                            Text("ーーーーーーーーーーーーー")
                                .foregroundColor(.white)

                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .frame(width: 250, height: 300)
                                .opacity(0.2)
                                .overlay(alignment: .top) {
                                    Text(item.detail)
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .frame(width: 240)
                                        .padding(.vertical)
                                }
                        } // VStack
                    } // ScrollView
                    .padding(.vertical, 30)

                }
        } // ZStack(全体)
        .opacity(inputDetail.opacity)

        .sheet(isPresented: $isPresentedEditItem) {

            // NOTE: itemがnilでない場合のみボタンを有効にしているため、ボタンアクション時には値を強制アンラップします。
            EditItemView(itemVM: itemVM,
                         isPresentedEditItem: $isPresentedEditItem,
                         itemIndex: itemIndex,
                         passItemData: item,
                         editItemStatus: .update)
        } // sheet(アイテム更新シート)

        .onAppear {
            withAnimation(.linear(duration: 0.2)) {
                inputDetail.opacity = 1.0
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
                        isShowItemDetail: .constant(false),
                        isPresentedEditItem: .constant(false)
        )
    }
}
