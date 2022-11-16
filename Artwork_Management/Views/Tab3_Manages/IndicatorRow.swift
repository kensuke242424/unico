//
//  IndicatorView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct IndicatorRow: View {

    @Binding var inputManage: InputManage
    let item: Item
    let color: UsedColor

    @State private var animationValue: Int = 0

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
                                .font(.system(size: 8, weight: .light, design: .default)).opacity(0.5)
                                .offset(y: 3)
                        }
                        .offset(x: -50, y: 2)

                        VStack {
                            Text("|")
                                .opacity(0.2)
                            Text(String(guide * 2))
                                .font(.system(size: 8, weight: .light, design: .default)).opacity(0.5)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 1.5)) {
                        animationValue = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).value
                    }
                }
            }

            .onChange(of: inputManage.indicatorWidthLimit) { _ in
                animationValue = 0

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 1.5)) {
                        animationValue = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).value
                    }
                }
            }

            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 1.5)) {
                        animationValue = indicatorElement(item: item, limit: inputManage.indicatorWidthLimit.value).value
                    }
                }
            }
            .onDisappear {
                animationValue = 0
            }
    }

    private func indicatorElement(item: Item, limit: Int) -> (value: Int, guide: Int) {

        // 各データごとのインジケータガイドの基準値
        let inventoryGuide: Int = 50
        let priceGuide: Int = 1000
        let salesGuide: Int = 10000

        switch inputManage.indicatorValueStatus {

            // NOTE: limit値を用いて、ゲージ幅の限界値を変化させる(ゲージ上限が10倍(limit = 10)の時、value値を10%に)
            // NOTE: value値が、「limit値以下」かつ「0ではない」場合に、切り捨てられて0にならないようにする
        case .stock:
            let resultValue = item.inventory < limit && item.inventory != 0 ? 1 : item.inventory / limit

            return (value: resultValue, guide: inventoryGuide * limit)

        case .price:
            let resultValue = item.price < limit * 10 && item.price != 0 ? 1 : item.price / 10 / limit

            return (value: resultValue, guide: priceGuide * limit)

        case .sales:
            let resultValue = item.sales < limit * 100 && item.sales != 0 ? 1 : item.sales / 100 / limit

            return (value: resultValue, guide: salesGuide * limit)

        }
    }
}

struct IndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorRow(inputManage: .constant(InputManage()), item: TestItem().testItem, color: .red)
    }
}
