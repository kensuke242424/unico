//
//  ManageCustomizeSideMenu.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/16.
//

import SwiftUI

enum UpDownOrder: CaseIterable {
    case up, down

    var icon: Image {
        switch self {
        case .up: return Image(systemName: "arrow.up.square.fill")
        case .down: return Image(systemName: "arrow.down.app.fill")
        }
    }
}

enum SortType: CaseIterable {
    case value, name, updateTime, createTime

    var text: String {
        switch self {
        case .value: return "取得データ順"
        case .name: return "名前順"
        case .createTime: return "作成日順"
        case .updateTime: return "更新日順"
        }
    }
}

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
    var sortType: SortType = .value
    var upDownOrder: UpDownOrder = .up
    var indicatorWidthLimit: IndicatorWidthLimit = .medium
    var indicatorValueStatus: IndicatorValueStatus = .sales
    var isTagGroup: Bool = true
}

struct ManageCustomizeSideMenu: View {

    @Binding var inputManage: InputManageCustomizeSideMenu

    var body: some View {

        ZStack {
            Color.clear
                .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color.customDarkGray2).opacity(0.8)
                .frame(height: 530)

                .overlay(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 30) {
                        VStack(alignment: .leading) {

                            Label("タググループ", systemImage: inputManage.isTagGroup == true ? "tag.fill" : "tag.slash")
                            Divider().background(.white)

                            Toggle("", isOn: $inputManage.isTagGroup).labelsHidden()
                        }

                        VStack(alignment: .leading) {
                            Label("取得データ", systemImage: "cube.fill")
                            Divider().background(.white)

                            Picker("ゲージ表示の要素", selection: $inputManage.indicatorValueStatus) {

                                ForEach(IndicatorValueStatus.allCases, id: \.self) { value in
                                    value.icon
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 130)
                        }

                        VStack(alignment: .leading) {
                            Label("条件指定", systemImage: "books.vertical.fill")
                            Divider().background(.white)
                            Picker("要素の条件並び替え", selection: $inputManage.sortType) {
                                ForEach(SortType.allCases, id: \.self) { value in
                                    Text(value.text)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 150, alignment: .leading)
                        }

                        VStack(alignment: .leading) {
                            Label("上り降り順", systemImage: "arrow.up.arrow.down")
                            Divider().background(.white)

                            Picker("上り降り順の選択", selection: $inputManage.upDownOrder) {
                                ForEach(UpDownOrder.allCases, id: \.self) { value in
                                    value.icon
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 130)
                        }

                        VStack(alignment: .leading) {

                            Label("ゲージ上限", systemImage: "align.horizontal.left.fill")
                            Divider().background(.white)

                            Picker("ゲージ表示の要素", selection: $inputManage.indicatorWidthLimit) {
                                ForEach(IndicatorWidthLimit.allCases, id: \.self) { value in
                                    Text(value.text)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 130)
                        }

                    }
                    .foregroundColor(.white)
                    .offset(x: 15)
                } // overlay

        }
    }
}

struct ManageCustomizeSideMenu_Previews: PreviewProvider {
    static var previews: some View {
        ManageCustomizeSideMenu(inputManage: .constant(InputManageCustomizeSideMenu()))
    }
}
