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

    @Binding var inputHome: InputHome
    @Binding var commerceResults: CartResults

    @State private var commerceButtonDisable: Bool = false
    @State private var commerceButtonOpacity: CGFloat =  1.0

    var body: some View {
        VStack {
            HStack {

                Button {
                    switch inputHome.cartState {
                    case .medium:
                        inputHome.cartState = .large
                    case .large:
                        inputHome.cartState = .medium
                    case .hidden:
                        inputHome.cartState = .medium
                    }

                } label: {
                    Image(systemName: "shippingbox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            if commerceResults.resultItemAmount <= 50 {
                                Image(systemName: "\(commerceResults.resultItemAmount).circle.fill")
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
                    Text(String(commerceResults.resultPrice))
                        .foregroundColor(.black)
                        .font(.title.bold())
                    Spacer()
                }

                Spacer()

                Button(
                    action: {
                        print("取引確定ボタンタップ")
                        inputHome.doCommerce = true
                        inputHome.cartState = .hidden
                        inputHome.commerceState = .hidden
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
                .disabled(commerceButtonDisable)
                .opacity(commerceButtonOpacity)
            } // HStack
            .frame(height: 80)
            .padding(.horizontal, 20)
            .animation(nil, value: commerceResults.resultPrice)
            .animation(nil, value: commerceResults.resultItemAmount)
        } // VStack 決済シートレイアウト

        .onChange(of: inputHome.doCommerce) { _ in
            commerceButtonDisable = inputHome.doCommerce ? true : false
            commerceButtonOpacity = inputHome.doCommerce ? 0.3 : 1.0
        }

        .onAppear {
            print("CommerceSheet_onAppear")
        }
    } // body
} // View
