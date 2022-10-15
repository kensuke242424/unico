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

    // .medium表示時の要素表示数
    private let listLimit: Int = 0

    var body: some View {

        // NOTE: 親View、ScrollResizableSheetの設定「.main」「.additional」
        //       .main ⇨ シート呼び出し時に表示される要素を設定します。
        //       .additional ⇨ シート内のスクロール全体に表示するアイテムを設定します。
        switch halfSheetScroll {

        case .main:

            // NOTE: アイテム取引かごシート表示時のアイテム表示数をプロパティ「listLimit」の値分で制限します。
            //       リミット数以降の要素はスクロールにより表示します。
            if basketItems != [] {
                ForEach(Array(basketItems.enumerated()), id: \.element) { offset, element in

                    if listLimit > offset {
                        BasketItemRow(itemVM: itemVM,
                                      resultItemAmount: $resultItemAmount,
                                      resultPrice: $resultPrice,
                                      actionRowIndex: $actionRowIndex,
                                      basketItems: $basketItems,
                                      item: element)
                    } // if
                } // ForEach
            } else {
                Text("かごの中にアイテムはありません")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            } // if listLimit

        case .additional:

            if basketItems.count > listLimit {
                ForEach(Array(basketItems.enumerated()), id: \.element) { offset, element in

                    if listLimit <= offset {
                        BasketItemRow(itemVM: itemVM,
                                      resultItemAmount: $resultItemAmount,
                                      resultPrice: $resultPrice,
                                      actionRowIndex: $actionRowIndex,
                                      basketItems: $basketItems,
                                      item: element)
                    } // if listLimit
                } // ForEach
                .padding()
                .frame(width: UIScreen.main.bounds.width, height: 120)
            }
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

                            // カート内アイテム数カウントが１だった時、アイテムを削除するかをユーザに確認します。
                            if count == 1 {
                                isShowAlert.toggle()
                                return
                            }

                            // マイナスボタン
                            if let newActionIndex = itemVM.items.firstIndex(of: item) {
                                actionRowIndex = newActionIndex
                                resultItemAmount -= 1
                            } // if let

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
                            if let newActionIndex = itemVM.items.firstIndex(of: item) {
                                actionRowIndex = newActionIndex
                                resultItemAmount += 1
                            } // if let

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
                            resultItemAmount -= 1
                            resultPrice -= item.price
                            basketItems.removeAll(where: { $0 == item })
                        }
                    } message: {
                        Text("かごからアイテムを削除しますか？")
                    }
                } // VStack
            } // HStack
        } // VStack(全体)

        // NOTE: かごのアイテム総数の変化を受け取り、どのアイテムが更新されたかを判定し、カウントを増減します。
        //       メインのカードView側からのアイテム追加とカウントを同期させるために必要です。
        .onChange(of: resultItemAmount) { [resultItemAmount] newItemAmount in
            if item == itemVM.items[actionRowIndex] {
                count = resultItemAmount < newItemAmount ? count + 1 : count - 1
                resultPrice = resultItemAmount < newItemAmount ? resultPrice + item.price : resultPrice - item.price
            } // if
        } // .onChange

        // NOTE: 新規アイテム追加時、roeViewのonAppearが発火します。
        //       アイテム要素追加時は(-)判定は発生しないので、判定分岐はせず、アイテムカウントに+1
        .onAppear {
            print("BasketItemRow_onAppear")
            count += 1
            resultPrice += item.price
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
