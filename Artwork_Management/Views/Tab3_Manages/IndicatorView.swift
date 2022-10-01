//
//  IndicatorView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct IndicatorView: View {

    @State private var animationValue: Int = 0
    let size = UIScreen.main.bounds
    let salesValue: Int
    let tagColor: Color

    var body: some View {
        Rectangle()
           .frame(width: size.width - 150, height: 13)
           .foregroundColor(.clear)
           .overlay(alignment: .leading) {
               Rectangle()
                   .frame(width: CGFloat(animationValue) / 1000, height: 13)
                   .foregroundColor(tagColor)
                   .opacity(0.7)
                   .shadow(radius: 2, x: 7, y: 4)
           } // case 黄
           .onAppear {
//               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                   withAnimation(.linear(duration: 0.8)) {

                       self.animationValue = salesValue
                   }
//               }
           }
           .onDisappear {
               self.animationValue = 0
           }
    }
}

struct IndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorView(salesValue: 220000, tagColor: .red)
    }
}
