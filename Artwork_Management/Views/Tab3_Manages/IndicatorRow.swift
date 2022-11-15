//
//  IndicatorView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct IndicatorRow: View {

    let value: Int
    let color: UsedColor

    @State private var animationValue: Int = 0

    var body: some View {

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
                            Text("100000")
                                .font(.system(size: 8, weight: .light, design: .default)).opacity(0.5)
                                .offset(y: 3)
                        }
                        .offset(x: -50, y: 2)

                        VStack {
                            Text("|")
                                .opacity(0.2)
                            Text("200000")
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
                    .frame(width: CGFloat(animationValue) / 1000, height: 13, alignment: .leading)
                    .foregroundColor(value != 0 ? color.color : .gray)
                    .opacity(value != 0 ? 0.5 : 0.2)
                    .shadow(radius: 1)
                    .shadow(radius: 2, x: 7, y: 4)
            }

            .overlay(alignment: .leading) {
                if value == 0 {
                    Text("売上データなし")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }



            .onAppear {
                withAnimation(.linear(duration: 0.8)) {
                    animationValue = value
                }
            }
            .onDisappear {
                animationValue = 0
            }
    }
}

struct IndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorRow(value: 220000, color: .red)
    }
}
