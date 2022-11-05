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
    @Binding var inputHome: InputHome
    @Binding var inputStock: InputStock

    @State private var commerceButtonDisable: Bool = false
    @State private var commerceButtonOpacity: CGFloat =  1.0

    var body: some View {
        VStack {
            HStack {

                Button {
                    switch inputHome.cartHalfSheet {
                    case .medium:
                        inputHome.cartHalfSheet = .large
                    case .large:
                        inputHome.cartHalfSheet = .medium
                    case .hidden:
                        inputHome.cartHalfSheet = .medium
                    }

                } label: {
                    Image(systemName: "shippingbox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            if inputStock.resultCartAmount <= 50 {
                                Image(systemName: "\(inputStock.resultCartAmount).circle.fill")
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
                    Text(String(inputStock.resultCartPrice))
                        .foregroundColor(.black)
                        .font(.title.bold())
                    Spacer()
                }

                Spacer()

                Button(
                    action: {
                        print("取引確定ボタンタップ")

                        // 各アイテムデータに結果を反映
                        for index in itemVM.items.indices {
                            if itemVM.items[index].amount != 0 {
                                print("index\(index)アイテムデータ反映開始")
                                itemVM.items[index].sales += itemVM.items[index].price * itemVM.items[index].amount
                                withAnimation(.spring(response: 0.6)) {
                                    itemVM.items[index].inventory -= itemVM.items[index].amount
                                }

                                itemVM.items[index].amount = 0
                                print("index\(index)アイテムデータ反映終了")
                            }
                        }
                        inputStock.resultCartPrice = 0
                        inputStock.resultCartAmount = 0

                        inputHome.doCommerce = true
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
                .disabled(inputHome.doCommerce)
                .opacity(inputHome.doCommerce == true ? 0.3 : 1.0)
            } // HStack
            .frame(height: 80)
            .padding(.horizontal, 20)
            .animation(nil, value: inputStock.resultCartPrice)
            .animation(nil, value: inputStock.resultCartAmount)
        } // VStack 決済シートレイアウト

        .onChange(of: inputHome.doCommerce) { _ in

            if inputHome.doCommerce {

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    inputHome.doCommerce = false
                    print("遅延後doCommerceをfalse")
                }

            }
        }

        .onAppear {
            print("CommerceSheet_onAppear")
        }
    } // body
} // View
