//
//  BlurView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/30.
//

import SwiftUI

// Since App Supports iOS 14...
struct BlurView: UIViewRepresentable {

    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))

        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        //
    }
}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        BlurView(style: .systemChromeMaterialDark)
    }
}
