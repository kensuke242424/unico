//
//  BounceAnimationView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/22.
//

import SwiftUI

enum CustomFont {
    case chalkduster, avenirNextUltraLight

    var font: String {
        switch self {
        case .chalkduster: return "Chalkduster"
        case .avenirNextUltraLight: return "AvenirNext-UltraLight"
        }
    }
}

struct BounceAnimationView: View {
    let characters: [String.Element]

    @State var offsetYForBounce: CGFloat = -10
    @State var opacity: CGFloat = 0
    @State var baseTime: Double
    @State var customFont: CustomFont = .avenirNextUltraLight

    let timer = Timer.publish(every: 4, on: .current, in: .common).autoconnect()

    init(text: String, startTime: Double) {
        self.characters = Array(text)
        self.baseTime = startTime
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< characters.count) { num in
                Text(String(self.characters[num]))
                    .font(.custom(customFont.font, fixedSize: 24))
                    .offset(x: 0, y: offsetYForBounce)
                    .opacity(opacity)
                    .animation(.spring(response: 0.2,
                                       dampingFraction: 0.5,
                                       blendDuration: 0.1).delay( Double(num) * 0.1 ), value: offsetYForBounce)
            }
            .onReceive(timer) { _ in
                // in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    opacity = 0
                    offsetYForBounce = -10
                }
                // out
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    opacity = 1
                    offsetYForBounce = 0
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.0 + baseTime)) {
                    opacity = 1
                    offsetYForBounce = 0
                }
            }
        }
    }
}

struct BounceAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        BounceAnimationView(text: "Loading...", startTime: 0.0)
    }
}
