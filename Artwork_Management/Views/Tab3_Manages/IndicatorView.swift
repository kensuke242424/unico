//
//  IndicatorView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/01.
//

import SwiftUI

struct IndicatorView: View {

    let size = UIScreen.main.bounds
    let salesValue: Int
    let tagColor: Color

    var body: some View {
        Rectangle()
           .frame(width: size.width - 150, height: 13)
           .foregroundColor(.clear)
           .overlay(alignment: .leading) {
               Rectangle()
                   .frame(width: CGFloat(salesValue) / 1000, height: 13)
                   .foregroundColor(tagColor)
                   .opacity(0.7)
                   .shadow(color: .gray, radius: 3, x: 4, y: 4)
           } // case 黄
    }
}

struct IndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorView(salesValue: 200000, tagColor: .red)
    }
}
