//
//  LocalNotificationView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import SwiftUI

struct LocalNotificationView: View {
    @EnvironmentObject var vm: MomentLogViewModel
    @Environment(\.colorScheme) var colorScheme
    let screen = UIScreen.main.bounds

    var body: some View {
        VStack {
            ZStack {
                ForEach(Array(vm.localNotifications.enumerated()), id: \.element) { index, element in
                    switch element.type {
                    case .outItemStock:
                        MessageBoard(element, index)
                    }
                }
            } // ZStack

            Spacer()
        } // VStack
    }
    @ViewBuilder
    func MessageBoard(_ element: MomentLog, _ index: Int) -> some View {

        Text(element.message)
            .tracking(1)
            .fontWeight(.black)
            .foregroundColor(.red)
            .opacity(0.5)
            .frame(maxWidth: screen.width * 0.8)
            .padding(10)
            .background(
                .white.shadow(.drop(color: .black.opacity(0.25),radius: 10)),
                        in: RoundedRectangle(cornerRadius: 35)
            )
            .opacity(0.9)
            .offset(y: CGFloat(index) * 10 + 50)
            .opacity(index == (vm.localNotifications.count - 1) ? 1 : 0.4)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + element.exitTime) {
                    withAnimation {
                        vm.localNotifications.removeAll(where: {$0.id == element.id})
                    }
                }
            }
    }
}

/// ローカルに対しての通知ビュータイプと要素を管理する列挙体。
enum LocalNotificationType: Equatable, Hashable {
    case outItemStock

    var type: LocalNotificationType {
        return self
    }

    /// 通知に渡すメッセージテキスト。
    var message: String {
        switch self {
        case .outItemStock:
            return "アイテムの在庫が不足しています"
        }
    }
    /// 通知が画面上に残る時間
    var exitTime: CGFloat {
        switch self {
        case .outItemStock:
            return 1.5
        }
    }
}

struct LocalNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        LocalNotificationView()
    }
}
