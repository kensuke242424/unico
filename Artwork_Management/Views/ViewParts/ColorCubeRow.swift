//
//  JumpAnimationView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/22.
//

import SwiftUI

struct ColorCubeView: View {

    @Binding var colorSet: MemberColor

    private let columnsV: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    var body: some View {

        LazyVGrid(columns: columnsV, spacing: 40) {
            ForEach(MemberColor.allCases, id: \.self) { color in
                ColorCubeRow(color1: color.color2, color2: color.colorAccent,
                             startTime: Double(color.index) * 0.5)
            }
        }
        .frame(width: getRect().width - 60)
    }
}

struct ColorCubeRow: View {

    let color1: Color
    let color2: Color

    @State var offsetYLoopBounce: CGFloat = -30
    @State var offsetYTapBounce: CGFloat = 0
    @State var cubeScale: CGFloat = 1.0
    @State var loopColorScale: CGFloat = 1.0
    @State var tapColorScale: CGFloat = 0.5
    @State var tapColorOpacity: CGFloat = 0.0
    @State var loopAngle = Angle(degrees: 0.0)
    @State var tapAngle = Angle(degrees: 0.0)
    @State var baseTime: Double
    @State var customFont: CustomFont = .avenirNextUltraLight

    let timer = Timer.publish(every: 7, on: .current, in: .common).autoconnect()
    let character: Image = Image(systemName: "cube")

    init(color1: Color, color2: Color, startTime: Double) {
        self.color1 = color1
        self.color2 = color2
        self.baseTime = startTime
    }

    var body: some View {

        character
            .foregroundColor(.white)
            .font(.custom(customFont.font, fixedSize: 50)).opacity(0.7)
            .background {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]),
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 37)
                    .overlay {
                        Ellipse()
                            .stroke(color2, lineWidth: 5)
                            .blur(radius: 3)
                            .frame(width: 40, height: 10)
                            .opacity(tapColorOpacity)
                            .scaleEffect(tapColorScale)
                            .scaleEffect(loopColorScale)
                    }
            }
            .offset(x: 0, y: offsetYLoopBounce)
            .offset(x: 0, y: offsetYTapBounce)
            .rotationEffect(loopAngle)
            .rotationEffect(tapAngle)
            .scaleEffect(cubeScale)

            .animation(.spring(response: 2.0,
                               dampingFraction: 2.5,
                               blendDuration: 1.5).delay(0.1), value: offsetYLoopBounce)
            .animation(.spring(response: 0.8,
                               dampingFraction: 0.5,
                               blendDuration: 1.5).delay(0.1), value: cubeScale)
            .animation(.spring(response: 0.8,
                               dampingFraction: 0.5,
                               blendDuration: 1.5).delay(0.1), value: loopColorScale)
            .animation(.spring(response: 0.2,
                               dampingFraction: 0.5,
                               blendDuration: 1.5).delay(0.1), value: tapColorScale)
            .animation(.spring(response: 0.5,
                               dampingFraction: 0.5,
                               blendDuration: 1.5).delay(0.1), value: tapColorOpacity)
            .animation(.spring(response: 3.0,
                               dampingFraction: 3.5,
                               blendDuration: 1.5).delay(0.1), value: loopAngle)
            .animation(.spring(response: 0.4,
                               dampingFraction: 3.5,
                               blendDuration: 1.5).delay(1.1), value: tapAngle)
            .animation(.spring(response: 0.1,
                               dampingFraction: 3.5,
                               blendDuration: 1.5).delay(1.5), value: offsetYTapBounce)
            .onTapGesture {
                offsetYTapBounce -= CGFloat(Int.random(in: 5...20))
                cubeScale = 1.3
                tapColorScale = 3.0
                tapColorOpacity = 0.5
                tapAngle = Angle(degrees: Double(Int.random(in: -30...30)))

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    tapColorOpacity = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    cubeScale = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    tapColorScale = 0.5
                }
            }

            .onReceive(timer) { _ in
                // in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0 + baseTime) {
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                    offsetYLoopBounce = -20
                    loopColorScale = 1.2
                    loopAngle = Angle(degrees: 10.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + baseTime) {
                    loopAngle = Angle(degrees: 20.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                }
                // out
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + baseTime) {
                    offsetYLoopBounce = 0
                    loopAngle = Angle(degrees: 10.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                    loopColorScale = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0 + baseTime) {
                    loopAngle = Angle(degrees: 0.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0 + baseTime) {
                    offsetYLoopBounce = -20
                    loopAngle = Angle(degrees: -10.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 + baseTime) {
                    loopAngle = Angle(degrees: -20.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                }
                // out
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0 + baseTime) {
                    offsetYLoopBounce = 0
                    loopAngle = Angle(degrees: -10.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 7.0 + baseTime) {
                    loopAngle = Angle(degrees: 0.0)
                    if offsetYTapBounce < 0 { offsetYTapBounce += 10 }
                }
            }

            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.0 + baseTime)) {
                    offsetYLoopBounce = 0
                }
            }

    }
}

struct ColorCubeView_Previews: PreviewProvider {
    static var previews: some View {
        ColorCubeView(colorSet: .constant(.gray))
    }
}
