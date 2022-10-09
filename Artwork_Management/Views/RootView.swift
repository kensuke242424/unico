//
//  RootView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/10.
//

import SwiftUI

import SwiftUI
import ResizableSheet

struct RootView: View {
    var windowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene
    }

    var resizableSheetCenter: ResizableSheetCenter? {
        windowScene.flatMap(ResizableSheetCenter.resolve(for:))
    }

    var body: some View {
        LogInView()
            .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
}
