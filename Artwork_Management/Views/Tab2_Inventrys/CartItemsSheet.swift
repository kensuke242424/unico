//
//  BasketItems.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/12.
//

import SwiftUI
import SDWebImageSwiftUI

struct CartItemsSheet: View {

    enum HalfSheetScroll {
        case main
        case additional
    }

    @StateObject var cartVM: CartViewModel

    let halfSheetScroll: HalfSheetScroll
    let memberColor: ThemeColor
    private let listLimit: Int = 0

    var body: some View {

        // NOTE: ライブラリ ScrollResizableSheetの設定「.main」「.additional」
        //       .main ⇨ シート呼び出し時に表示される要素を設定します。
        //       .additional ⇨ シート内のスクロール全体に表示するアイテムを設定します。
        switch halfSheetScroll {

        case .main:

            // NOTE: アイテム取引かごシート表示時のアイテム表示数をプロパティ「listLimit」の値分で制限します。
            //       リミット数以降の要素はスクロールにより表示します。
            if cartVM.resultCartAmount != 0 {
                ForEach(Array(cartVM.cartItems.enumerated()), id: \.element) { offset, element in

                    if listLimit > offset {
                        if element.amount > 0 {
                            CartItemRow(cartVM: cartVM,
                                        itemRow: element,
                                        memberColor: memberColor)
                        }
                    } // if
                } // ForEach
            } else {
                Text("かごの中にアイテムはありません")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            } // if listLimit

        case .additional:

            if cartVM.resultCartAmount > listLimit {
                ForEach(Array(cartVM.cartItems.enumerated()), id: \.element) { offset, element in

                    if listLimit <= offset {
                        if element.amount > 0 {
                            CartItemRow(cartVM: cartVM,
                                        itemRow: element,
                                        memberColor: memberColor)
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

    @EnvironmentObject var userVM: UserViewModel

    @StateObject var cartVM: CartViewModel
    
    let itemRow: Item
    let memberColor: ThemeColor

    @State private var basketItemCount: Int = 0
    @State private var isShowAlert: Bool = false
    @State private var countUpDisable: Bool = false

    var body: some View {

        VStack {

            Divider()
                .background(.gray)

            HStack {
                
                CartItemPhoto(photoURL: itemRow.photoURL)

                Spacer()

                VStack(alignment: .trailing, spacing: 30) {
                    Text(itemRow.name == "" ? "No Name" : itemRow.name)
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .font(.title3.bold())
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 20) {

                        HStack(alignment: .bottom) {
                            Text("¥")
                                .foregroundColor(.black)
                            Text(itemRow.price != 0 ? String(itemRow.price) : "-")
                                .foregroundColor(.black)
                                .font(.title3)
                                .fontWeight(.heavy)
                                .padding(.trailing)
                        }
                        // マイナスボタン
                        Button {

                            if let newActionIndex = cartVM.cartItems.firstIndex(where: { $0.id == itemRow.id }) {
                                cartVM.actionItemIndex = newActionIndex
                                print("newActionIndex: \(newActionIndex)")
                            } else {
                                print("カート内-ボタンのアクションIndexの取得に失敗しました")
                                return
                            } // if let

                            // カート内アイテム数カウントが１だった時、アイテムを削除するかをユーザに確認します。
                            if cartVM.cartItems[cartVM.actionItemIndex].amount == 1 {
                                isShowAlert.toggle()
                                return
                            }

                            cartVM.cartItems[cartVM.actionItemIndex].amount -= 1
                            cartVM.resultCartPrice -= cartVM.cartItems[cartVM.actionItemIndex].price
                            cartVM.resultCartAmount -= 1

                            if countUpDisable {
                                countUpDisable.toggle()
                            }

                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(memberColor.color2)
                        }
                        Text(String(itemRow.amount))
                            .foregroundColor(.black)
                            .fontWeight(.black)

                        // プラスボタン
                        Button {

                            if let newActionIndex = cartVM.cartItems.firstIndex(where: { $0.id == itemRow.id }) {

                                cartVM.actionItemIndex = newActionIndex

                                cartVM.cartItems[newActionIndex].amount += 1
                                cartVM.resultCartPrice += cartVM.cartItems[newActionIndex].price
                                cartVM.resultCartAmount += 1
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
                                .foregroundColor(memberColor.color2)
                                .opacity(countUpDisable ? 0.3 : 1.0)
                        }
                        .disabled(countUpDisable)
                    }
                    .offset(y: 8)
                    .alert("確認", isPresented: $isShowAlert) {
                        Button("削除", role: .destructive) {
                            // データ削除処理
                            cartVM.cartItems[cartVM.actionItemIndex].amount -= 1
                            cartVM.resultCartPrice -= cartVM.cartItems[cartVM.actionItemIndex].price
                            cartVM.resultCartAmount -= 1
                        }
                    } message: {
                        Text("かごから\(itemRow.name == "" ? "No Name" : itemRow.name)を削除しますか？")
                    }
                } // VStack
            } // HStack
        } // VStack(全体)
    } // body
} // view


/// Viewの更新から切り離せるか試してみた
struct CartItemPhoto: View {
    let photoURL: URL?
    var body: some View {
        
        if let photoURL {
            WebImage(url: photoURL)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.gray)
                .frame(width: 100, height: 100)
                .overlay {
                    VStack {
                        Image(systemName: "cube.transparent.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                            .foregroundColor(.white)
                        Text("No Image.")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(0.7)
                    }
                }
        }
    }
}

struct CartItemsSheet_Previews: PreviewProvider {
    static var previews: some View {
        CartItemsSheet(cartVM: CartViewModel(),
                       halfSheetScroll: .additional,
                       memberColor: .blue)
    }
}
