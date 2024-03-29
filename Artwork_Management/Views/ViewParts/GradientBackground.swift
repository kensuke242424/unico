//
//  GradientBackbround.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/22.
//

import SwiftUI

struct GradientBackground: View {

    let color1: Color
    let color2: Color

    var body: some View {
        ZStack {

            BlurView(style: .systemThickMaterialDark)

            LinearGradient(gradient: Gradient(colors: [color1, color2]),
                           startPoint: .top, endPoint: .bottom)
            .opacity(0.9)
            .blur(radius: 10)
        }
        .ignoresSafeArea()
    }
}

struct GradientBackbround_Previews: PreviewProvider {
    static let memberColor: ThemeColor = .brawn
    static var previews: some View {
        GradientBackground(color1: memberColor.color1, color2: memberColor.colorAccent)
    }
}
