//
//  NotificationBoard.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI
import SDWebImageSwiftUI

struct NotificationBoard: View {

    @EnvironmentObject var vm: NotificationViewModel
    @Environment(\.colorScheme) var colorScheme
    let screen = UIScreen.main.bounds

    var body: some View {
        VStack {
            ZStack {
                ForEach(Array(vm.boardFrames.enumerated()), id: \.element) { index, element in
                    switch element.type {
                    case .addItem, .updateItem, .join, .commerce:
                        IconAndMessage(element, index)
                    case .outOfStock:
                        MessageOnly(element, index)
                    }
                }
            } // ZStack
            Spacer()
        } // VStack
    }
    @ViewBuilder
    func MessageOnly(_ element: BoardFrame, _ index: Int) -> some View {
        let backColor = colorScheme == .dark ? Color.black : Color.white
        let shadowColor = colorScheme == .dark ? Color.white : Color.black

        Text(element.message)
            .tracking(1)
            .fontWeight(.black)
            .foregroundColor(element.color)
            .opacity(0.5)
            .frame(maxWidth: screen.width * 0.8)
            .padding(10)
            .background(
                .white.shadow(.drop(color: .black.opacity(0.25),radius: 10)),
                        in: RoundedRectangle(cornerRadius: 35)
            )
            .opacity(0.9)
            .offset(y: CGFloat(index) * 10)
            .opacity(index == (vm.boardFrames.count - 1) ? 1 : 0.4)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + element.waitTime) {
                    withAnimation {
                        vm.boardFrames.removeAll(where: {$0.id == element.id})
                    }
                }
            }
    }
    @ViewBuilder
    func IconAndMessage(_ element: BoardFrame, _ index: Int) -> some View {

        let backColor = colorScheme == .dark ? Color.black : Color.white
        let shadowColor = colorScheme == .dark ? Color.white : Color.black
        
        HStack {
            if let url = element.imageURL {
                WebImage(url: url)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .padding(.trailing, 10)
            } else {
                Circle()
                    .fill(element.color.gradient)
                    .frame(width: 60, height: 60)
                    .shadow(radius: 1)
                    .overlay {
                        Image(systemName: element.type.symbol)
                            .resizable().scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                    }
                    .padding(.trailing, 10)
            }

            Text(element.message)
                .tracking(1)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(0.5)
        }
        .frame(width: screen.width * 0.9)
        .padding(10)
        .background(
            backColor.shadow(.drop(color: shadowColor.opacity(0.25),radius: 10)),
                    in: RoundedRectangle(cornerRadius: 35))
        .offset(y: CGFloat(index) * 10)
        .opacity(index == (vm.boardFrames.count - 1) ? 1 : 0.4)
        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: -50)))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + element.waitTime) {
                withAnimation {
                    vm.boardFrames.removeAll(where: {$0.id == element.id})
                }
            }
        }
    }
}

enum NotificationType {
    case addItem(Item)
    case updateItem(Item)
    case outOfStock
    case commerce(Int)
    case join(User)

    var type: NotificationType {
        return self
    }

    /// 通知に渡すメッセージテキスト。
    var message: String {
        switch self {
        case .addItem(let item):
            return "\(item.name) のアイテム情報が追加されました。"
        case .updateItem(let item):
            return "\(item.name) のアイテム情報が更新されました。"
        case .outOfStock:
            return "アイテムの在庫が不足しています。"
        case .commerce(let count):
            return "カート内 \(count) 個のアイテム情報が更新されました。"
        case .join(let user):
            return "\(user.name) さんがチームに参加しました。"
        }
    }
    /// 通知アイコンに用いられる画像URL。WebImageによって表示される。
    var imageURL: URL? {
        switch self {
        case .addItem(let item):
            return item.photoURL
        case .updateItem(let item):
            return item.photoURL
        case .outOfStock:
            return nil
        case .commerce:
            return nil
        case .join(let user):
            return user.iconURL
        }
    }
    var symbol: String {
        switch self {
        case .addItem, .updateItem:
            return "shippingbox.fill"
        case .outOfStock:
            return ""
        case .commerce:
            return "cart.fill"
        case .join:
            return "person.fill"
        }
    }

    /// 通知に用いられるカラー。主にアイコンの背景色。
    var color: Color {
        switch self {
        case .addItem, .updateItem, .join:
            return Color.white
        case .outOfStock:
            return Color.red
        case .commerce:
            return Color.mint
        }
    }
    /// 通知が画面上に残る時間
    var waitTime: CGFloat {
        switch self {
        case .addItem, .updateItem:
            return 2.0
        case .outOfStock:
            return 2.0
        case .commerce:
            return 3.0
        case .join:
            return 5.0
        }
    }
}

struct NotificationBoard_Previews: PreviewProvider {
    static var vm = NotificationViewModel()
    static var previews: some View {
        VStack {
            NotificationBoard()
            Button("通知を確認") {
                withAnimation(.easeOut(duration: 0.5)) {
                    vm.setNotify(type: .outOfStock)
                }
            }
        }
        .environmentObject(vm)
    }
}
