//
//  BasketItems.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/12.
//

import SwiftUI

enum HalfSheetScroll {
    case main
    case additional
}

struct BasketItemsSheet: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var basketItems: [Item]
    @Binding var resultItemAmount: Int
    @Binding var resultPrice: Int

    @Binding var actionRowIndex: Int
    let halfSheetScroll: HalfSheetScroll

    private let listLimit: Int = 0

    var body: some View {

        // NOTE: 親View、ScrollResizableSheetの設定「.main」「.additional」
        //       .main ⇨ シート呼び出し時に表示される要素を設定します。
        //       .additional ⇨ シート内のスクロール全体に表示するアイテムを設定します。
        switch halfSheetScroll {

        case .main:

            // NOTE: アイテム取引かごシート表示時のアイテム表示数をプロパティ「listLimit」の値分で制限します。
            //       現在、シート呼び出し時の初期アイテム表示は3つまでとしています。以降の要素はスクロールにより表示します。
            if basketItems != [] {
                ForEach(0 ..< basketItems.count, id: \.self) { index in
                    if listLimit > index {
                        BasketItemRow(itemVM: itemVM,
                                      resultItemAmount: $resultItemAmount,
                                      resultPrice: $resultPrice,
                                      actionRowIndex: $actionRowIndex,
                                      basketItems: $basketItems,
                                      item: basketItems[index])
                    } // if
                } // ForEach
            } else {
                Text("かごの中にアイテムはありません")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            }

        case .additional:

            if basketItems != [] {
                if basketItems.count > listLimit {
                    ForEach(listLimit ..< basketItems.count, id: \.self) { index in
                        BasketItemRow(itemVM: itemVM,
                                      resultItemAmount: $resultItemAmount,
                                      resultPrice: $resultPrice,
                                      actionRowIndex: $actionRowIndex,
                                      basketItems: $basketItems,
                                      item: basketItems[index])
                    } // ForEach
                    .padding()
                    .frame(width: UIScreen.main.bounds.width, height: 120)
                } else {
                    Spacer()
                        .frame(width: UIScreen.main.bounds.width,
                               height: 10)
                }
            } else {
                Spacer()
                    .frame(width: UIScreen.main.bounds.width,
                           height: 10)
            } // if let
        } // switch
    } // body
} // View

// ✅ カスタムView: かご内の一要素分のレイアウト
struct BasketItemRow: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var resultItemAmount: Int
    @Binding var resultPrice: Int
    @Binding var actionRowIndex: Int

    @Binding var basketItems: [Item]
    let item: Item

    @State private var count: Int = 0
    @State private var isShowAlert: Bool = false

    var body: some View {

        VStack {

            Divider()
                .background(.gray)

            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.customLightGray1)
                    .opacity(0.3)

                Spacer()

                VStack(alignment: .trailing, spacing: 30) {
                    Text("\(item.name)")
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .font(.title3.bold())
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 30) {

                        HStack(alignment: .bottom) {
                            Text("¥")
                                .foregroundColor(.black)
                            Text(String(item.price))
                                .foregroundColor(.black)
                                .font(.title3)
                                .fontWeight(.heavy)
                            Spacer()
                        }
                        Button {
                            // マイナスボタン
                            if count == 1 {
                                isShowAlert.toggle()
                            } else {
                                resultItemAmount -= 1
                                resultPrice -= item.price
                            }

                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.customlDarkPurple1)
                        }
                        Text(String(count))
                            .foregroundColor(.black)
                            .fontWeight(.black)
                        Button {
                            // プラスボタン
                            resultItemAmount += 1
                            resultPrice += item.price
                            print(count)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.customlDarkPurple1)
                        }
                    }
                    .offset(y: 8)
                    .alert("確認", isPresented: $isShowAlert) {
                        Button("削除", role: .destructive) {
                            // データ削除処理
                            basketItems.removeAll(where: { $0 == item })
                        }
                    } message: {
                        Text("かごからアイテムを削除しますか？")
                    }
                } // VStack
            } // HStack
        } // VStack(全体)

        // NOTE: かごのアイテム総数の変化を受け取り、どのアイテムが更新されたかを判定し、カウントを増減します。
        .onChange(of: resultItemAmount) { [resultItemAmount] newItemAmount in

            if item == itemVM.items[actionRowIndex] {
                count = resultItemAmount < newItemAmount ? count + 1 : count - 1
            }
        } // .onChange

        // NOTE: 新規アイテム追加onAppear時は(-)判定は発生しないので、判定分岐はせず、アイテムカウントに+1
        .onAppear {
            print("BasketItemRow_onAppear")
//            if item == itemVM.items[actionRowIndex] {
//                print("\(item.name)がバスケットに追加されました。")
                count += 1
//            }
        } // .onAppear

    } // body
} // view

struct BasketItemsSheet_Previews: PreviewProvider {
    static var previews: some View {
        BasketItemsSheet(itemVM: ItemViewModel(),
                         basketItems: .constant(
                            [
                                Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
                                     price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
                                Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
                                     price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
                                Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "", price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date())
                            ]),
                         resultItemAmount: .constant(0),
                         resultPrice: .constant(20000),
                         actionRowIndex: .constant(0),
                         halfSheetScroll: .main)
    }
}
