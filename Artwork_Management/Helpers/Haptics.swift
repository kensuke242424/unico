//
//  Haptics.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/15.
//

import SwiftUI

// デバイスの振動によるフィードバック
public func hapticSuccessNotification() {
    let g = UINotificationFeedbackGenerator()
    g.prepare()
    g.notificationOccurred(.success)
}

public func hapticActionNotification() {
    let g = UINotificationFeedbackGenerator()
    g.prepare()
    g.notificationOccurred(.warning)
}

public func hapticErrorNotification() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.error)
}
