//
//  ButtonViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/11.
//

import Foundation

enum ButtonStyle {
    case library
    case stock
    case manege
    case account
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
            return ButtonIcon(icon: change ?  "" : "",
                              badge: change ?  "" : "")

        case .stock:
            return ButtonIcon(icon: change ?  "magnifyingglass" : "magnifyingglass",
                              badge: change ?  "" : "")

        case .manege:
            return ButtonIcon(icon: change ? "shippingbox.fill" : "shippingbox.fill",
                              badge: change ? "plus.circle.fill" : "plus.circle.fill")

        case .account:
            return ButtonIcon(icon: change ?  "" : "",
                              badge: change ?  "" : "")
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
        case 3:
            buttonStyle = .account
            return buttonStyle
        default:
            return buttonStyle
        }
    } // func buttonStyleChenged

}
