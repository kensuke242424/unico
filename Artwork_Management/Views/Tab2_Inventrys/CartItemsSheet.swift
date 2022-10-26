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

struct CartItemsSheet: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var commerceResults: CartResults
    @Binding var inputStock: InputStock
    @Binding var inputHome: InputHome

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
            if commerceResults.resultCartItems != [] {
                ForEach(Array(commerceResults.resultCartItems.enumerated()), id: \.element) { offset, element in

                    if listLimit > offset {
                        BasketItemRow(itemVM: itemVM,
                                      commerceResults: $commerceResults,
                                      inputStock: $inputStock,
                                      inputHome: $inputHome,
                                      item: element)
                    } // if
                } // ForEach
            } else {
                Text("かごの中にアイテムはありません")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            } // if listLimit

        case .additional:

            if commerceResults.resultCartItems.count > listLimit {
                ForEach(Array(commerceResults.resultCartItems.enumerated()), id: \.element) { offset, element in

                    if listLimit <= offset {
                        BasketItemRow(itemVM: itemVM,
                                      commerceResults: $commerceResults,
                                      inputStock: $inputStock,
                                      inputHome: $inputHome,
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

    @Binding var commerceResults: CartResults
    @Binding var inputStock: InputStock
    @Binding var inputHome: InputHome

    let item: Item

    @State private var basketItemCount: Int = 0
    @State private var isShowAlert: Bool = false
    @State private var countUpDisable: Bool = false

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

                    HStack(alignment: .bottom, spacing: 20) {

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

                            if let newActionIndex = itemVM.items.firstIndex(of: item) {
                                inputStock.actionRowIndex = newActionIndex
                                print("newActionIndex: \(newActionIndex)")
                            } else {
                                print("アクションIndexの取得に失敗しました")
                                return
                            } // if let
                            // カート内アイテム数カウントが１だった時、アイテムを削除するかをユーザに確認します。
                            if basketItemCount == 1 {
                                isShowAlert.toggle()
                                return
                            }
                            // マイナスボタン

                            commerceResults.resultItemAmount -= 1

                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.customlDarkPurple1)
                        }
                        Text(String(basketItemCount))
                            .foregroundColor(.black)
                            .fontWeight(.black)
                        Button {
                            // プラスボタン
                            if let newActionIndex = itemVM.items.firstIndex(of: item) {
                                inputStock.actionRowIndex = newActionIndex
                                commerceResults.resultItemAmount += 1
                            } else {
                                print("アクションIndexの取得に失敗しました")
                            } // if let

                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.customlDarkPurple1)
                                .opacity(countUpDisable ? 0.3 : 1.0)
                        }
                        .disabled(countUpDisable)
                    }
                    .offset(y: 8)
                    .alert("確認", isPresented: $isShowAlert) {
                        Button("削除", role: .destructive) {
                            // データ削除処理
                            commerceResults.resultItemAmount -= 1
                            commerceResults.resultPrice -= item.price
                            commerceResults.resultCartItems.removeAll(where: { $0 == item })
                        }
                    } message: {
                        Text("かごからアイテムを削除しますか？")
                    }
                } // VStack
            } // HStack

            // 決済確定ボタンタップを検知して、対象のアイテム情報を更新します。
            .onChange(of: inputHome.doCommerce) { commerce in
                if commerce {
                    print(inputHome.doCommerce)
                    guard let updateItemIndex = itemVM.items.firstIndex(of: item) else { return }
                    print("updateItemIndex: \(updateItemIndex)")
                    print("basketItemCount: \(basketItemCount)")
                    if item == itemVM.items[updateItemIndex] {
                        itemVM.items[updateItemIndex].sales += item.price * basketItemCount
                        itemVM.items[updateItemIndex].inventory -= basketItemCount
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                        inputHome.doCommerce = false
                        print(inputHome.doCommerce)
                    }
                }
            }

        } // VStack(全体)

        // NOTE: かごのアイテム総数の変化を受け取り、どのアイテムが更新されたかを判定し、カウントを増減します。
        //       メインのカードView側からのアイテム追加とカウントを同期させるために必要です。
        .onChange(of: commerceResults.resultItemAmount) { [beforeAmount = commerceResults.resultItemAmount] afterAmount in

            if item == itemVM.items[inputStock.actionRowIndex] {
                if beforeAmount < afterAmount {
                    basketItemCount += 1
                    commerceResults.resultPrice += item.price

                } else if beforeAmount > afterAmount {
                    // NOTE: カート内のアイテム削除処理が発生した際、onchange内のカウント減処理が他のアイテムに適用されてしまうため、
                    //       アイテム削除処理が発火する条件である「count1」の時は、マイナス処理をスキップしています。
                    if basketItemCount == 1 { return }
                    if item == itemVM.items[inputStock.actionRowIndex] {
                        print("カウント減実行")
                        commerceResults.resultPrice -= item.price
                        basketItemCount -= 1
                    }
                }
            } // if
        } // .onChange

        .onChange(of: basketItemCount) { newCount in
            if newCount == item.inventory {
                if item == itemVM.items[inputStock.actionRowIndex] {
                    countUpDisable = true
                }
            } else {
                if item == itemVM.items[inputStock.actionRowIndex] {
                    countUpDisable = false
                }
            }
        }

        // NOTE: 新規アイテム追加時、roeViewのonAppearが発火します。
        //       アイテム要素追加時は(-)判定は発生しないので、判定分岐はせず、アイテムカウントに+1
        .onAppear {
            basketItemCount += 1
            commerceResults.resultPrice += item.price
        } // .onAppear

    } // body
} // view
//
//struct BasketItemsSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        BasketItemsSheet(itemVM: ItemViewModel(),
//                         basketItems: .constant(
//                            [
//                                Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
//                                     price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
//                                Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
//                                     price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
//                                Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "", price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date())
//                            ]),
//                         resultItemAmount: .constant(0),
//                         resultPrice: .constant(20000),
//                         actionRowIndex: .constant(0),
//                         doCommerce: .constant(false),
//                         halfSheetScroll: .main)
//    }
//}
