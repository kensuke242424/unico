//
//  IndicatorView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct IndicatorRow: View {

    @Binding var inputManage: InputManageCustomizeSideMenu
    let item: RootItem
    let color: UsedColor

    @State private var animationValue: CGFloat = 0

    var body: some View {

        let value = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).value
        let guide = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).guide

        Rectangle()
            .frame(width: getRect().width / 2, height: 13)
            .foregroundColor(.clear)
            .overlay(alignment: .leading) {
                Rectangle()
                    .frame(width: 300, height: 13)
                    .foregroundColor(.clear)
                    .overlay {
                        VStack {
                            Text("|")
                                .opacity(0.2)
                            Text(String(guide))
                                .font(.system(size: 10, weight: .light, design: .default)).opacity(0.5)
                                .offset(y: 3)
                        }
                        .offset(x: -50, y: 2)

                        VStack {
                            Text("|")
                                .opacity(0.2)
                            Text(String(guide * 2))
                                .font(.system(size: 10, weight: .light, design: .default)).opacity(0.5)
                                .offset(y: 3)
                        }
                        .offset(x: 50, y: 2)
                    }
                    .border(.white.opacity(0.05))
                    .foregroundColor(.white)
            }

            .overlay(alignment: .leading) {
                Rectangle()
                    .frame(width: CGFloat(animationValue), height: 13, alignment: .leading)
                    .foregroundColor(color.color)
                    .opacity(0.6)
                    .shadow(radius: 1)
                    .shadow(radius: 2, x: 7, y: 4)
            }

            .overlay(alignment: .leading) {
                if value == 0 {
                    Text("データなし")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .offset(x: 20)
                }
            }

            .onChange(of: inputManage.indicatorValueStatus) { _ in
                animationValue = 0
                let newValue = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).value
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 1.5)) {
                        animationValue = newValue
                    }
                }
            }

            .onChange(of: inputManage.indicatorWidthLimit) { _ in
                animationValue = 0
                let newValue = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).value

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 1.5)) {
                        animationValue = newValue
                    }
                }
            }

            .onAppear {
                let startValue = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).value
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 1.5)) {
                        animationValue = startValue
                    }
                }
            }
            .onDisappear {
                animationValue = 0
            }
    }

    private func indicatorElement(item: RootItem, limit: Int) -> (value: CGFloat, guide: Int) {

        // value値はCGFloat型で返すため、limit値のCGFloat型を用意
        let cgFloatLimit: CGFloat = CGFloat(limit)

        switch inputManage.indicatorValueStatus {

        // NOTE: limit値を用いて、ゲージ幅の限界値を変化させる(ゲージ上限が10倍(limit = 10)の時、value値を10%に)
        case .stock:
            let resultValue: CGFloat = CGFloat(item.inventory) * 2 / cgFloatLimit
            let inventoryGuide: Int = 50 * limit

            return (value: resultValue, guide: inventoryGuide)

        case .price:
            let resultValue: CGFloat = CGFloat(item.price) / 20 / cgFloatLimit
            let priceGuide: Int = 2000 * limit

            return (value: resultValue, guide: priceGuide)

        case .sales:
            let resultValue: CGFloat = CGFloat(item.sales) / 100 / cgFloatLimit
            let salesGuide: Int = 10000 * limit

            return (value: resultValue, guide: salesGuide)

        }
    }
}
