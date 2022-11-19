//
//  Parts.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/15.
//

import SwiftUI

struct GradientLine: View {

    let color1: Color
    let color2: Color

    var body: some View {
        LinearGradient(gradient: Gradient(colors: [color1, color2]),
                                   startPoint: .leading, endPoint: .trailing)
            .frame(height: 1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Parts_Previews: PreviewProvider {
    static var previews: some View {
        GradientLine(color1: .white, color2: .gray)
    }
}
