//
//  UsefulButtonView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/06.
//

import SwiftUI
import ResizableSheet

struct UsefulButton: View {

    @StateObject var buttonVM: ButtonViewModel = ButtonViewModel()

    @Binding var tabIndex: Int
    @Binding var isPresentedNewItem: Bool
    @Binding var state: ResizableSheetState

    @State private var change: Bool = false
    @State private var buttonStyle: ButtonStyle = .library
    @State private var buttonIcon: ButtonIcon = ButtonIcon(icon: "shippingbox.fill",
                                              badge: "plus.circle.fill")

    var body: some View {
        Button {

            self.buttonStyle = buttonVM.buttonStyleChenged(tabIndex: tabIndex)
            self.buttonIcon = buttonVM.iconChenge(style: buttonStyle, change: change)

            switch buttonStyle {

            case .library:
                print("library画面ボタンアクション実行")

            case .stock:
                print("stock画面ボタンアクション実行")

            case .manege:
                print("manege画面ボタンアクション実行")
                self.isPresentedNewItem.toggle()

            case .account:
                print("account画面ボタンアクション実行")
            } // switch

        } label: {

            // ✅カスタムView
            ButtonStyleView(buttonStyle: $buttonStyle,
                            tabIndex: $tabIndex,
                            buttonIcon: $buttonIcon)

        } // Button
        .offset(x: UIScreen.main.bounds.width / 3 - 5,
                y: UIScreen.main.bounds.height / 3 - 20)

        // NOTE: ボタンアイコンが条件で変化する発火場所です。
//        .onChange(of: tabIndex) {newIndex in
//            //
//        } // onChange(tabIndex)
    } // body
} // View

struct ButtonStyleView: View {

    @Binding var buttonStyle: ButtonStyle
    @Binding var tabIndex: Int
    @Binding var buttonIcon: ButtonIcon

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
                Image(systemName: buttonIcon.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .shadow(radius: 10, x: 3, y: 5)

                    // アイコン右上に付くバッジ
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: buttonIcon.badge)
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

        var windowScene: UIWindowScene? {
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    return windowScene
                }
        var resizableSheetCenter: ResizableSheetCenter? {
                   windowScene.flatMap(ResizableSheetCenter.resolve(for:))
               }

        return UsefulButton(tabIndex: .constant(2),
                            isPresentedNewItem: .constant(false),
                            state: .constant(.medium)
        )
        .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
}
