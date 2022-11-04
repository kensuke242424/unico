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
            if inputStock.resultCartAmount != 0 {
                ForEach(Array(itemVM.items.enumerated()), id: \.element) { offset, element in

                    if listLimit > offset {
                        if element.amount > 0 {
                            CartItemRow(itemVM: itemVM,
                                          inputStock: $inputStock,
                                          inputHome: $inputHome,
                                          itemRow: element)
                        }

                    } // if
                } // ForEach
            } else {
                Text("かごの中にアイテムはありません")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            } // if listLimit

        case .additional:

            if inputStock.resultCartAmount > listLimit {
                ForEach(Array(itemVM.items.enumerated()), id: \.element) { offset, element in

                    if listLimit <= offset {
                        if element.amount > 0 {
                            CartItemRow(itemVM: itemVM,
                                          inputStock: $inputStock,
                                          inputHome: $inputHome,
                                          itemRow: element)
                        }

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
                        // マイナスボタン
                        Button {

                            if let newActionIndex = itemVM.items.firstIndex(where: { $0.id == itemRow.id }) {
                                inputHome.actionItemIndex = newActionIndex
                                print("newActionIndex: \(newActionIndex)")
                            } else {
                                print("カート内-ボタンのアクションIndexの取得に失敗しました")
                                return
                            } // if let

                            // カート内アイテム数カウントが１だった時、アイテムを削除するかをユーザに確認します。
                            if itemVM.items[inputHome.actionItemIndex].amount == 1 {
                                isShowAlert.toggle()
                                return
                            }

                            itemVM.items[inputHome.actionItemIndex].amount -= 1
                            inputStock.resultCartPrice -= itemVM.items[inputHome.actionItemIndex].price
                            inputStock.resultCartAmount -= 1

                            if countUpDisable {
                                countUpDisable.toggle()
                            }

                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.customlDarkPurple1)
                        }
                        Text(String(itemRow.amount))
                            .foregroundColor(.black)
                            .fontWeight(.black)

                        // プラスボタン
                        Button {

                            if let newActionIndex = itemVM.items.firstIndex(where: { $0.id == itemRow.id }) {

                                inputHome.actionItemIndex = newActionIndex

                                itemVM.items[newActionIndex].amount += 1
                                inputStock.resultCartPrice += itemVM.items[newActionIndex].price
                                inputStock.resultCartAmount += 1
                                if itemRow.amount == itemRow.inventory {
                                    countUpDisable.toggle()
                                }
                            } else {
                                print("カート内+ボタンのアクションIndexの取得に失敗しました")
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
                            itemVM.items[inputHome.actionItemIndex].amount -= 1
                            inputStock.resultCartPrice -= itemVM.items[inputHome.actionItemIndex].price
                            inputStock.resultCartAmount -= 1
                        }
                    } message: {
                        Text("かごからアイテムを削除しますか？")
                    }
                } // VStack
            } // HStack

        } // VStack(全体)

    } // body
} // view
//
struct CartItemsSheet_Previews: PreviewProvider {
    static var previews: some View {
        CartItemsSheet(itemVM: ItemViewModel(),
                       inputStock: .constant(InputStock()),
                       inputHome: .constant(InputHome()),
                       halfSheetScroll: .additional)
    }
}
