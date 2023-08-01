//
//  ManageCustomizeSideMenu.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/16.
//

import SwiftUI

enum IndicatorWidthLimit: CaseIterable {
    case medium, lerge

    var text: String {
        switch self {
        case .medium: return "小"
        case .lerge: return "大"
        }
    }

    var value: Int {
        switch self {
        case .medium: return 1
        case .lerge: return 10
        }
    }
}

enum IndicatorValueStatus: CaseIterable {
    case stock, price, sales

    var text: String {
        switch self {
        case .stock: return "在庫"
        case .price: return "価格"
        case .sales: return "売上"
        }
    }

    var icon: Image {
        switch self {
        case .stock: return Image(systemName: "shippingbox.fill")
        case .price: return Image(systemName: "yensign.circle.fill")
        case .sales: return Image(systemName: "banknote.fill")
        }
    }
}

struct InputManageCustomizeSideMenu {
    var sortType: ItemsSortType = .sales
    var upDownOrder: UpDownOrder = .up
    var indicatorWidthLimit: IndicatorWidthLimit = .medium
    var indicatorValueStatus: IndicatorValueStatus = .sales
    var isTagGroup: Bool = true
}

struct ManageCustomizeSideMenu: View {

    @Binding var inputManage: InputManageCustomizeSideMenu
    @Binding var isOpen: Bool
    @GestureState var dragOffset: CGFloat = 0.0

    var body: some View {

        ZStack {
            Color.clear
                .ignoresSafeArea()

            Rectangle()
//                .foregroundColor(Color.customDarkGray2).opacity(0.6)
                .background(BlurView(style: .systemUltraThinMaterialDark)).opacity(0.8)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(height: 540)

                .overlay(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 33) {
                        VStack(alignment: .leading) {

                            Label("タググループ", systemImage: inputManage.isTagGroup == true ? "tag.fill" : "tag.slash").font(.subheadline)
                            Divider().background(.white)

                            Toggle("", isOn: $inputManage.isTagGroup).labelsHidden()
                        }

                        VStack(alignment: .leading) {
                            Label("データ選択", systemImage: "cube.fill").font(.subheadline)
                            Divider().background(.white)

                            Picker("ゲージ表示の要素", selection: $inputManage.indicatorValueStatus) {

                                ForEach(IndicatorValueStatus.allCases, id: \.self) { value in
                                    value.icon
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 130, height: 30)
                        }

                        VStack(alignment: .leading) {
                            Label("並び替え", systemImage: "arrow.up.arrow.down").font(.subheadline)
                            Divider().background(.white)

                            Picker("並び替え", selection: $inputManage.upDownOrder) {
                                ForEach(UpDownOrder.allCases, id: \.self) { value in
                                    value.icon
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 130)
                        }

                        VStack(alignment: .leading) {
                            Label("並び替え条件", systemImage: "Items.vertical.fill").font(.subheadline)
                            Divider().background(.white)

                            Picker("並び替え条件", selection: $inputManage.sortType) {
                                ForEach(ItemsSortType.allCases, id: \.self) { value in
                                    Text(value.text)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 150, alignment: .leading)
                        }

                        VStack(alignment: .leading) {

                            Label("メーター上限値", systemImage: "align.horizontal.left.fill").font(.subheadline)
                            Divider().background(.white)

                            Picker("メーター上限値", selection: $inputManage.indicatorWidthLimit) {
                                ForEach(IndicatorWidthLimit.allCases, id: \.self) { value in
                                    Text(value.text)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 130)
                        }

                    }
                    .foregroundColor(.white)
                    .offset(x: 20)
                } // overlay
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .updating(self.$dragOffset, body: { (value, state, _) in

                            if value.translation.width > 0 {

                                state = value.translation.width

                            }})
                        .onEnded { value in
                            if value.translation.width > 70 {

                                withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                                    isOpen.toggle()
                                }
                            }
                        }

                )
                .animation(.interpolatingSpring(mass: 0.8, stiffness: 100, damping: 80, initialVelocity: 0.1), value: dragOffset)
        }
    }
}

struct ManageCustomizeSideMenu_Previews: PreviewProvider {
    static var previews: some View {
        ManageCustomizeSideMenu(inputManage: .constant(InputManageCustomizeSideMenu()), isOpen: .constant(false))
    }
}
