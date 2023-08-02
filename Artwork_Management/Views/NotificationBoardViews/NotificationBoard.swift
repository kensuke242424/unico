//
//  NotificationBoard.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

struct NotificationBoard: View {

    @EnvironmentObject var vm: NotificationViewModel
    @Environment(\.colorScheme) var colorScheme
    let screen = UIScreen.main.bounds

    var body: some View {
        VStack {
            ZStack {
                ForEach(Array(vm.boardFrames.enumerated()), id: \.element) { index, element in

                    BoardView(element, index)
                }
            } // ZStack
            Spacer()
        } // VStack
    }
    @ViewBuilder
    func BoardView(_ element: BoardFrame, _ index: Int) -> some View {

        let backColor = colorScheme == .dark ? Color.black : Color.white
        let shadowColor = colorScheme == .dark ? Color.white : Color.black
        
        HStack {
            Circle().frame(width: 60, height: 60)
            Text(element.message)
                .tracking(1)
                .fontWeight(.bold)
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
    case commerce(Int)
    case join(User)

    var message: String {
        switch self {
        case .addItem:
            return "アイテムを追加しました。"
        case .updateItem:
            return "アイテムデータを更新しました。"
        case .commerce:
            return "カート内の処理を完了しました。"
        case .join(let user):
            return "\(user.name)がチームに参加しました。"
        }
    }

    var imageURL: URL? {
        switch self {
        case .addItem(let item):
            return item.photoURL
        case .updateItem(let item):
            return item.photoURL
        case .commerce:
            return nil
        case .join(let user):
            return user.iconURL
        }
    }

    var color: Color {
        switch self {
        case .addItem, .updateItem:
            return Color.white
        case .commerce:
            return Color.mint
        case .join:
            return Color.white
        }
    }

    var waitTime: CGFloat {
        switch self {
        case .addItem, .updateItem:
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
                    vm.setNotify(type: .commerce(10))
                }
            }
        }
        .environmentObject(vm)
    }
}
