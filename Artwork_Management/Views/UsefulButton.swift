//
//  UsefulButtonView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/06.
//

import SwiftUI

enum ButtonStyle {
    case library
    case stock
    case manege
    case account
}

struct UsefulButton: View {

    @Binding var tabIndex: Int
    @Binding var isPresentedNewItem: Bool
    @State private var buttonStyle: ButtonStyle = .library

    var body: some View {
        Button {

            if buttonStyle == .manege {
                self.isPresentedNewItem.toggle()
            } else {
                print("マネージ画面でのみ、新規アイテムシートが表示されます。")
            }

        } label: {

            // ✅カスタムView
            ButtonStyleView()

        } // Button
        .offset(x: UIScreen.main.bounds.width / 3 - 5,
                y: UIScreen.main.bounds.height / 3 - 20)

        .onChange(of: tabIndex) {newIndex in

            switch newIndex {
            case 0:
                buttonStyle = .library
            case 1:
                buttonStyle = .stock
            case 2:
                buttonStyle = .manege
            case 3:
                buttonStyle = .account
            default:
                print("tabIndex_error")
            }
        } // onChange(tabIndex)
    } // body

    func buttonIconStyleSelect(style: ButtonStyle) -> [String: String] {

        switch style {
        case .library:
            print("ライブラリ画面時のアイコン")
            return ["icon": "", "badge": ""]

        case .stock:
            print("ストック画面時のアイコン")
            return ["icon": "", "badge": ""]
        case .manege:
            print("マネージ画面時のアイコン")
            return ["icon": "shippingbox.fill", "badge": "plus.circle.fill"]

        case .account:
            print("システム画面時のアイコン")
            return ["icon": "", "badge": ""]
        }
    } // func buttonStyleIcon

} // View

struct ButtonStyleView: View {
    var body: some View {

        // 円形のボタン土台
        Circle()
            .foregroundColor(.white)
            .frame(width: 70)
            .padding()
            .blur(radius: 1)
            .shadow(color: .gray, radius: 10, x: 4, y: 11)

            // ボタンのアイコン
            .overlay {
                Image(systemName: "shippingbox.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .shadow(radius: 10, x: 3, y: 5)

                    // アイコン右上に付くバッジ
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .offset(x: 10, y: -10)
                    } // overlay
            } // overlay
    } // body
} // View

struct UsefulButton_Previews: PreviewProvider {
    static var previews: some View {
        UsefulButton(tabIndex: .constant(2), isPresentedNewItem: .constant(false))
    }
}
