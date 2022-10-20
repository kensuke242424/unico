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

    @Binding var commerceState: ResizableSheetState
    @Binding var basketState: ResizableSheetState
    @Binding var resultPrice: Int
    @Binding var resultItemAmount: Int
    @Binding var doCommerce: Bool

    @State private var commerceButtonDisable: Bool = false
    @State private var commerceButtonOpacity: CGFloat =  1.0

    var body: some View {
        VStack {
            HStack {

                Button {
                    switch basketState {
                    case .medium:
                        basketState = .large
                    case .large:
                        basketState = .medium
                    case .hidden:
                        basketState = .medium
                    }

                } label: {
                    Image(systemName: "shippingbox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            if resultItemAmount <= 50 {
                                Image(systemName: "\(resultItemAmount).circle.fill")
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
                    Text(String(resultPrice))
                        .foregroundColor(.black)
                        .font(.title.bold())
                    Spacer()
                }

                Spacer()

                Button(
                    action: {
                        print("取引確定ボタンタップ")
                        doCommerce = true
                        basketState = .hidden
                        commerceState = .hidden
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
            .animation(nil, value: resultPrice)
            .animation(nil, value: resultItemAmount)
        } // VStack 決済シートレイアウト

        .onChange(of: doCommerce) { _ in
            commerceButtonDisable = doCommerce ? true : false
            commerceButtonOpacity = doCommerce ? 0.3 : 1.0
        }

        .onAppear {
            print("CommerceSheet_onAppear")
        }
    } // body
} // View
