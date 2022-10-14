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
    @Binding var resultBasketItems: [Item]?

    var body: some View {
        VStack {
            HStack {

                Button {
                    basketState = .medium
                } label: {
                    Image(systemName: "shippingbox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            if resultItemAmount <= 50 {
                                Image(systemName: "\(resultItemAmount).circle")
                                    .foregroundColor(.black)
                                    .offset(y: -8)
                            } else {
                                Image(systemName: "50.circle").offset(y: -8)
                                    .foregroundColor(.black)
                                    .overlay(alignment: .topTrailing) {
                                        Text("＋")
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

                        resultBasketItems?.removeAll()
                        basketState = .hidden
                        // NOTE: .hiddenと値のリセット処理が重なるとうまくシートが閉じなかったので、ずらしています。
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            commerceState = .hidden
                            resultPrice = 0
                            resultItemAmount = 0
                        }
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
            } // HStack
            .frame(height: 100)
            .padding(.horizontal, 20)
            .animation(nil, value: resultPrice)
            .animation(.easeIn(duration: 1.0), value: resultPrice)
        } // VStack 決済シートレイアウト
        .onAppear {
            print("CommerceSheet_onAppear")
        }
    } // body
} // View
