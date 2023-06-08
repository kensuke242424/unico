//
//  ContentView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/22.
//

import SwiftUI

struct CubesProgressView: View {

    private let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    @State private var memberColor: ThemeColor = .blue
    @State private var cubeColors: [ThemeColor] = []

    var body: some View {

        ZStack {

            GradientBackbround(color1: memberColor.color1,
                               color2: memberColor.colorAccent)
            .opacity(0.5)
            .background(.thickMaterial)

            VStack(spacing: 70) {

                BounceAnimationView(text: "Loading...", startTime: 0.0)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.white)
                    .tracking(8)

                LazyVGrid(columns: columnsV, spacing: 40) {
                    ForEach(0..<cubeColors.count, id: \.self) { index in

                        ColorCubeRow(colorRow: cubeColors[index],
                                     startTime: Double(index) * 0.5, colorSet: $memberColor)

                    }
                }
                .frame(width: getRect().width - 60)
            } // VStack
        }
        .preferredColorScheme(.dark)
        // カラーをランダムで取り出し、キューブビューに割り当てる
        .onAppear {
            for _ in 0...3 {
                if let randomColor = ThemeColor.allCases.randomElement() {
                    self.cubeColors.append(randomColor)
                }
            }
        }

    } // body
} // View

struct StandByView_Previews: PreviewProvider {
    static var previews: some View {
        CubesProgressView()
    }
}
