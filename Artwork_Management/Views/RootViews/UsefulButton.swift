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

    @Binding var inputHome: InputHome

    @State private var offsetY: CGFloat = 0.0
    @State private var opacity: CGFloat = 0.0
    @State private var change: Bool = false
    @State private var buttonStyle: ButtonStyle = .stock
    @State private var buttonIcon: ButtonIcon = ButtonIcon(icon: "shippingbox.fill",
                                              badge: "plus.circle.fill")

    var body: some View {
        Button {

            switch buttonStyle {

            case .library:
                print("library画面ボタンアクション実行")

            case .stock:
                print("stock画面ボタンアクション実行")
                // NOTE: フォーカスを用いた入力フィールド開閉の都合上、ボタンによるfalseはしたくないため、
                //       toggle()は使用していません。
                inputHome.isShowSearchField.toggle()

            case .manege:
                print("manege画面ボタンアクション実行")
                inputHome.editItemStatus = .create
                inputHome.isPresentedEditItem.toggle()

            case .account:
                print("account画面ボタンアクション実行")
            } // switch

        } label: {

            // ✅カスタムView
            ButtonStyleView(buttonIcon: buttonIcon, buttonStyle: buttonStyle)

        } // Button
        .offset(x: UIScreen.main.bounds.width / 3 - 5,
                y: UIScreen.main.bounds.height / 3 - 10)
        .offset(y: offsetY)
        .opacity(opacity)
        .animation(.easeIn(duration: 0.1), value: opacity)

        .onChange(of: inputHome.cartHalfSheet) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                switch inputHome.cartHalfSheet {
                case .hidden: offsetY = 0.0
                case .medium: offsetY = -60.0
                case .large: offsetY = -60.0
                }
            }
        } // .onChange(cartState)

        .onChange(of: inputHome.homeTabIndex) { newIndex in
            buttonStyle = buttonVM.buttonStyleChenged(tabIndex: newIndex)
            buttonIcon = buttonVM.iconChenge(style: buttonStyle, change: change)

            if newIndex == 0 {
                opacity = 0.0
            } else {
                opacity = 1.0
            }
        } // onChange(tabIndex)
    } // body
} // View

struct ButtonStyleView: View {

    let buttonIcon: ButtonIcon
    let buttonStyle: ButtonStyle

    @State private var angle: CGFloat = 0.0

    var body: some View {

        // 円形のボタン土台
        Circle()
            .foregroundColor(.white)
            .frame(width: 65)
            .padding()
            .blur(radius: 1)

            // ボタンのアイコン
            .overlay {

                Group {
                    Image(systemName: buttonIcon.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .shadow(radius: 10, x: 3, y: 5)

                    // アイコン右上に付くバッジ
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: buttonIcon.badge)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .offset(x: 10, y: -10)
                        } // overlay

                        .overlay {
                            if buttonStyle == .stock {
                                Image(systemName: "questionmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 7)
                                    .offset(x: -3, y: -4)
                            }
                        }
                }
                .foregroundColor(.customDarkGray1)
                .animation(.easeIn(duration: 0.2), value: buttonIcon)
                .rotationEffect(Angle(degrees: angle), anchor: UnitPoint(x: 2.0, y: 2.0))
            } // overlay

            .onChange(of: buttonIcon) { _ in
                withAnimation(.easeIn(duration: 0.2)) {
                    self.angle = 50.0
                    print(angle)
                }
            } // .onChange(buttonIcon)

            .onChange(of: angle) { newAngle in
                if newAngle == 50.0 {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.angle = 0.0
                    }
                }
            } // .onChange(angle)

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

        return UsefulButton(inputHome: .constant(InputHome()))
        .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
}
