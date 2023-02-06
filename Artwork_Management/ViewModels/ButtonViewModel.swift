//
//  ButtonViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/11.
//

import SwiftUI

enum ButtonStyle {
    case library
    case stock
    case manege
}

class ButtonViewModel: ObservableObject {

    @Published var buttonStyle: [ButtonIcon] =
    [
        ButtonIcon(icon: "", badge: ""),
        ButtonIcon(icon: "", badge: ""),
        ButtonIcon(icon: "shippingbox.fill", badge: "plus.circle.fill"),
        ButtonIcon(icon: "", badge: "")
    ]

    // ✅メソッド: ボタンアイコンのレイアウトを切り替えるメソッドです。
    func iconChenge(style: ButtonStyle, change: Bool) -> ButtonIcon {

        switch style {

        case .library:
            return ButtonIcon(icon: change ?  "magnifyingglass" : "magnifyingglass",
                              badge: change ?  "circlebadge.fill" : "circlebadge.fill")

        case .stock:
            return ButtonIcon(icon: change ?  "magnifyingglass" : "magnifyingglass",
                              badge: change ?  "circlebadge.fill" : "circlebadge.fill")

        case .manege:
            return ButtonIcon(icon: change ? "chart.bar.xaxis" : "chart.bar.xaxis",
                              badge: change ? "circlebadge.fill" : "circlebadge.fill")
        } // switch
    } // func buttonStyleIcon

    // ✅メソッド: tabIndexを受け取って、enumのボタンスタイルを切り替えます。
    func buttonStyleChenged(tabIndex: Int) -> ButtonStyle {

        var buttonStyle: ButtonStyle = .library

        switch tabIndex {
        case 0:
            buttonStyle = .library
            return buttonStyle
        case 1:
            buttonStyle = .stock
            return buttonStyle
        case 2:
            buttonStyle = .manege
            return buttonStyle
        default:
            return buttonStyle
        }
    } // func buttonStyleChenged
}

// デバイスの振動によるフィードバック
public func hapticSuccessNotification() {
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.success)
    }

public func hapticErrorNotification() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.error)
}
