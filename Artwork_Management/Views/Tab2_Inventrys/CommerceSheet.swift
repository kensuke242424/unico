//
//  CommerceSheet.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/12.
//

import SwiftUI
import ResizableSheet

// NOTE: 取引対象のアイテムの決済を完了するシートです。
struct CommerceSheet: View {

    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var notifyVM: MomentLogViewModel
    @EnvironmentObject var logVM: LogViewModel

    @StateObject var cartVM: CartViewModel
    @Binding var inputTab: InputTab
    let teamID: String
    let memberColor: ThemeColor

    @State private var commerceButtonDisable: Bool = false
    @State private var commerceButtonOpacity: CGFloat =  1.0

    var body: some View {
        VStack {
            HStack {

                Button {
                    switch inputTab.showCart {
                    case .medium:
                        inputTab.showCart = .large
                    case .large:
                        inputTab.showCart = .medium
                    case .hidden:
                        inputTab.showCart = .medium
                    }

                } label: {
                    Image(systemName: "shippingbox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            if cartVM.resultCartAmount <= 50 {
                                Image(systemName: "\(commerceResults().amount).circle.fill")
                                    .foregroundColor(memberColor.color3)
                                    .offset(y: -8)
                            } else {
                                Image(systemName: "50.circle.fill").offset(y: -8)
                                    .foregroundColor(memberColor.color3)
                                    .overlay(alignment: .topTrailing) {
                                        Text("＋")
                                            .foregroundColor(memberColor.color3)
                                            .font(.caption)
                                            .offset(x: 7, y: -12)
                                    }
                            }
                        } // overlay
                } // Button
                HStack(alignment: .bottom) {
                    Text("¥")
                        .foregroundColor(.black)
                        .font(.title2.bold())
                    Text(commerceResults().price == 0 ? "-" : "\(commerceResults().price)")
                        .foregroundColor(.black)
                        .font(.title.bold())
                    Spacer()
                }

                Spacer()

                Button(
                    action: {
                        /// カート内各アイテムの更新前・更新後データがメソッドの返り値として渡ってくる
                        /// これらのデータを通知用の比較表示データとして渡す
                        let compareItems = cartVM.updateCommerceItemsAndGetCompare(teamID: teamID)
                        // 通知の作成
                        logVM.addLog(to: teamVM.team,
                                     by: userVM.user,
                                     type: .commerce(compareItems))
                        cartVM.doCommerce = true
                        hapticSuccessNotification()
                    },
                    label: {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(memberColor.color3)
                            .frame(width: 80, height: 50)
                            .shadow(radius: 2, x: 3, y: 3)
                            .overlay {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .foregroundColor(.white)
                            }
                    }
                ) // Button
                .disabled(cartVM.doCommerce)
                .opacity(cartVM.doCommerce == true ? 0.3 : 1.0)
            } // HStack
            .frame(height: userDeviseSize == .small ? 70 : 80)
            .padding(.horizontal, 20)
            .animation(nil, value: cartVM.resultCartPrice)
            .animation(nil, value: cartVM.resultCartAmount)
        } // VStack 決済シートレイアウト

        .onChange(of: cartVM.doCommerce) { _ in

            if cartVM.doCommerce {

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    cartVM.doCommerce = false
                }
            }
        }

    } // body
    private func commerceResults() -> (price: Int, amount: Int) {

        var resultPrices: Int = 0
        var resultAmounts: Int = 0

        for item in cartVM.cartItems where item.amount != 0 {
            resultPrices += item.amount * item.price
            resultAmounts += item.amount
        }

        return (price: resultPrices, amount: resultAmounts)
    }
} // View
