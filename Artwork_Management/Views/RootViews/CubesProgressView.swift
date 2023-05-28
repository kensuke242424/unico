//
//  ContentView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/22.
//

import SwiftUI

struct CubesProgressView: View {

    private let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    @State private var memberColor: ThemeColor = .gray

    var body: some View {

        ZStack {

            GradientBackbround(color1: memberColor.color1, color2: memberColor.color1)

            VStack(spacing: 70) {

                BounceAnimationView(text: "Loading...", startTime: 0.0)
                    .foregroundColor(.white)

                LazyVGrid(columns: columnsV, spacing: 40) {
                    ForEach(0 ..< 4, id: \.self) { index in
                        if let randomColor = ThemeColor.allCases.randomElement() {
                            ColorCubeRow(colorRow: randomColor,
                                         startTime: Double(index) * 0.5, colorSet: $memberColor)
                        }
                    }
                }
                .frame(width: getRect().width - 60)
            } // VStack
        }

    } // body
} // View

struct StandByView_Previews: PreviewProvider {
    static var previews: some View {
        CubesProgressView()
    }
}
