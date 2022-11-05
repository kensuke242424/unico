//
//  BasketItems.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/12.
//

import SwiftUI

struct CartItemsSheet: View {

    enum HalfSheetScroll {
        case main
        case additional
    }

    @StateObject var itemVM: ItemViewModel
    @Binding var cartResults: CartResults
    @Binding var inputStock: InputStock
    @Binding var inputHome: InputHome

    let halfSheetScroll: HalfSheetScroll

    // .medium表示時の要素表示数
    private let listLimit: Int = 0

    var body: some View {

        // NOTE: ライブラリ ScrollResizableSheetの設定「.main」「.additional」
        //       .main ⇨ シート呼び出し時に表示される要素を設定します。
        //       .additional ⇨ シート内のスクロール全体に表示するアイテムを設定します。
        switch halfSheetScroll {

        case .main:

            // NOTE: アイテム取引かごシート表示時のアイテム表示数をプロパティ「listLimit」の値分で制限します。
            //       リミット数以降の要素はスクロールにより表示します。
            if cartResults.resultCartItems != [] {
                ForEach(Array(cartResults.resultCartItems.enumerated()), id: \.element) { offset, element in

                    if listLimit > offset {
                        CartItemRow(itemVM: itemVM,
                                      commerceResults: $cartResults,
                                      inputStock: $inputStock,
                                      inputHome: $inputHome,
                                      itemRow: element)
                    } // if
                } // ForEach
            } else {
                Text("かごの中にアイテムはありません")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            } // if listLimit

        case .additional:

            if cartResults.resultCartItems.count > listLimit {
                ForEach(Array(cartResults.resultCartItems.enumerated()), id: \.element) { offset, element in

                    if listLimit <= offset {
                        CartItemRow(itemVM: itemVM,
                                      commerceResults: $cartResults,
                                      inputStock: $inputStock,
                                      inputHome: $inputHome,
                                      itemRow: element)
                    } // if listLimit
                } // ForEach
                .padding()
                .frame(width: UIScreen.main.bounds.width, height: 120)
            }
        } // switch
    } // body
} // View

// ✅ カスタムView: かご内の一要素分のレイアウト
struct CartItemRow: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var commerceResults: CartResults
    @Binding var inputStock: InputStock
    @Binding var inputHome: InputHome

    let itemRow: Item

    @State private var basketItemCount: Int = 0
    @State private var isShowAlert: Bool = false
    @State private var countUpDisable: Bool = false

    var body: some View {

        VStack {

            Divider()
                .background(.gray)

            HStack {

                ShowItemPhoto(photo: itemRow.photo, size: 100)

                Spacer()

                VStack(alignment: .trailing, spacing: 30) {
                    Text("\(itemRow.name)")
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .font(.title3.bold())
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 20) {

                        HStack(alignment: .bottom) {
                            Text("¥")
                                .foregroundColor(.black)
                            Text(String(itemRow.price))
                                .foregroundColor(.black)
                                .font(.title3)
                                .fontWeight(.heavy)
                                .padding(.trailing)
                        }
                        Button {

                            if let newActionIndex = itemVM.items.firstIndex(of: itemRow) {
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
                            if let newActionIndex = itemVM.items.firstIndex(of: itemRow) {
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
                            commerceResults.resultPrice -= itemRow.price
                            commerceResults.resultCartItems.removeAll(where: { $0 == itemRow })
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
                    guard let updateItemIndex = itemVM.items.firstIndex(of: itemRow) else { return }
                    print("updateItemIndex: \(updateItemIndex)")
                    print("basketItemCount: \(basketItemCount)")
                    if itemRow == itemVM.items[updateItemIndex] {
                        itemVM.items[updateItemIndex].sales += itemRow.price * basketItemCount
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

            if itemRow == itemVM.items[inputStock.actionRowIndex] {
                if beforeAmount < afterAmount {
                    basketItemCount += 1
                    commerceResults.resultPrice += itemRow.price

                } else if beforeAmount > afterAmount {
                    // NOTE: カート内のアイテム削除処理が発生した際、onchange内のカウント減処理が他のアイテムに適用されてしまうため、
                    //       アイテム削除処理が発火する条件である「count1」の時は、マイナス処理をスキップしています。
                    if basketItemCount == 1 { return }
                    if itemRow == itemVM.items[inputStock.actionRowIndex] {
                        print("カウント減実行")
                        commerceResults.resultPrice -= itemRow.price
                        basketItemCount -= 1
                    }
                }
            } // if
        } // .onChange

        .onChange(of: basketItemCount) { newCount in
            if newCount == itemRow.inventory {
                if itemRow == itemVM.items[inputStock.actionRowIndex] {
                    countUpDisable = true
                }
            } else {
                if itemRow == itemVM.items[inputStock.actionRowIndex] {
                    countUpDisable = false
                }
            }
        }

        // NOTE: 新規アイテム追加時、roeViewのonAppearが発火します。
        //       アイテム要素追加時は(-)判定は発生しないので、判定分岐はせず、アイテムカウントに+1
        .onAppear {
            basketItemCount += 1
            commerceResults.resultPrice += itemRow.price
        } // .onAppear

    } // body
} // view
//
struct CartItemsSheet_Previews: PreviewProvider {
    static var previews: some View {
        CartItemsSheet(itemVM: ItemViewModel(),
                       cartResults: .constant(CartResults()),
                       inputStock: .constant(InputStock()),
                       inputHome: .constant(InputHome()),
                       halfSheetScroll: .additional)
    }
}
