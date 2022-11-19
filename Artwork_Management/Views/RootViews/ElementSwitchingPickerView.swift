//
//  ElementSwitchingPickerView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/14.
//

import SwiftUI

enum ElementStatus: CaseIterable {

    case stock
    case price

    var text: String {
        switch self {
        case .stock: return "在庫"
        case .price: return "値段"
        }
    }

    var icon: Image {
        switch self {
        case .stock: return Image(systemName: "shippingbox.fill")
        case .price: return Image(systemName: "yensign.circle.fill")
        }
    }
}

struct ElementSwitchingPickerView: View {

    @Binding var switchElement: ElementStatus
    @Binding var tabIndex: Int

    @State private var offsetY: CGFloat = 0.0

    var body: some View {

        Picker("表示要素の切り替え", selection: $switchElement) {

            ForEach(ElementStatus.allCases, id: \.self) { value in
                value.icon
                    .tag(value.text)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: getRect().width * 0.3)
        .opacity(tabIndex == 0 ? 0.0 : 1.0)
        .onAppear {
            UISegmentedControl.appearance().backgroundColor = .black.withAlphaComponent(0.7)
            UISegmentedControl.appearance().selectedSegmentTintColor = .white
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.5)], for: .normal)
        }
    }
}

struct ElementSwitchingPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ElementSwitchingPickerView(switchElement: .constant(.stock), tabIndex: .constant(1))
    }
}
