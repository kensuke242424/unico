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

    @StateObject var itemVM: ItemViewModel
    @Binding var inputTab: InputTab
    @Binding var inputCart: InputCart
    let teamID: String

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
                            if inputCart.resultCartAmount <= 50 {
                                Image(systemName: "\(commerseResults().amount).circle.fill")
                                    .foregroundColor(.customLightBlue2)
                                    .offset(y: -8)
                            } else {
                                Image(systemName: "50.circle.fill").offset(y: -8)
                                    .foregroundColor(.customLightBlue2)
                                    .overlay(alignment: .topTrailing) {
                                        Text("＋")
                                            .foregroundColor(.customLightBlue2)
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
                    Text(String(commerseResults().price))
                        .foregroundColor(.black)
                        .font(.title.bold())
                    Spacer()
                }

                Spacer()

                Button(
                    action: {

                        itemVM.updateCommerseItems(teamID: teamID)
                        inputCart.resultCartPrice = 0
                        inputCart.resultCartAmount = 0
                        inputCart.doCommerce = true
                    },
                    label: {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.customlMiddlePurple1)
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
                .disabled(inputCart.doCommerce)
                .opacity(inputCart.doCommerce == true ? 0.3 : 1.0)
            } // HStack
            .frame(height: 80)
            .padding(.horizontal, 20)
            .animation(nil, value: inputCart.resultCartPrice)
            .animation(nil, value: inputCart.resultCartAmount)
        } // VStack 決済シートレイアウト

        .onChange(of: inputCart.doCommerce) { _ in

            if inputCart.doCommerce {

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    inputCart.doCommerce = false
                    print("DispatchQueue2秒後doCommerceをfalse")
                }
            }
        }

    } // body
    private func commerseResults() -> (price: Int, amount: Int) {

        var resultPrices: Int = 0
        var resultAmounts: Int = 0

        for item in itemVM.items where item.amount != 0 {
            resultPrices += item.amount * item.price
            resultAmounts += item.amount
        }

        return (price: resultPrices, amount: resultAmounts)
    }
} // View
