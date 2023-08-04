//
//  NotificationBoard.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI
import SDWebImageSwiftUI

/// チームのメンバー全員に届く通知を表示するビュー。
/// ビューの発火と同時に、自身が持つ通知の取得 -> 表示 -> 破棄 の処理が続く。
/// 所持通知が無くなると、ビューが閉じる。
/// 現在の通知対象 -> 「アイテムの追加・更新」「メンバーの加入」
struct TeamNotificationView: View {

    @EnvironmentObject var vm: TeamNotificationViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    let screen = UIScreen.main.bounds
    var uid: String? { teamVM.uid }
    var currentTeamMyMemberData: JoinMember? {
        guard let team = teamVM.team else { return nil }
        guard let index = teamVM.myMemberIndex else { return nil }
        return team.members[index]
    }

    @State private var currentNotification: TeamNotifyFrame?

    var body: some View {
        VStack {
            if let element = vm.currentNotification {
                switch element.type {
                case .addItem, .updateItem, .join, .commerce:
                    IconAndMessageView(element: element)
                }
            }
            Spacer()
        } // VStack
        .onChange(of: vm.currentNotification) { value in
            if value != nil { return }
            guard let myData = currentTeamMyMemberData else { vm.show = false; return }
            if let notification = myData.notifications.first {
                // 通知データがまだ残っている場合
                vm.currentNotification = notification
            } else {
                // 通知データが残っていない場合
                vm.show = false
            }
        }
        .onAppear {
            guard let myData = currentTeamMyMemberData else { vm.show = false; return }
            if let notification = myData.notifications.first {
                // 自身のMemberデータに通知が存在する
                vm.currentNotification = notification
            } else {
                // 通知データが存在しない
                vm.show = false
            }
        }
    }
}

/// アイコン+メッセージ型の通知ボード。
/// WebImageの画像ロード完了を待つため、表示までに少しタイムラグを持たせている。
fileprivate struct IconAndMessageView: View {

    fileprivate enum RemoveType {
        case local, all
    }
    /// 表示される通知ボードの要素データ
    let element: TeamNotifyFrame

    @EnvironmentObject var vm: TeamNotificationViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var state: Bool = false
    @GestureState var dragOffset: CGSize = .zero
    /// WebImageの画像ロード完了を待つ時間。出現時のアニメーション不具合を防ぐため。
    let loadWaitTime: CGFloat = 0.5
    let screen = UIScreen.main.bounds

    var body: some View {
        let backColor = colorScheme == .dark ? Color.black : Color.white

        HStack {
            if let url = element.imageURL {
                WebImage(url: url)
                    .resizable().scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 60, height: 60)
                    .background {
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(lineWidth: 1)
                            .fill(.orange)
                            .opacity(0.5)
                    }
                    .padding(.trailing, 10)
            } else {
                Circle()
                    .fill(.gray.gradient)
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
                .opacity(0.7)
                .padding(.trailing, 5)
        }
        .frame(width: screen.width * 0.9)
        .padding(10)
        .background(
            backColor.shadow(.drop(color: .black.opacity(0.25),radius: 10)),
                    in: RoundedRectangle(cornerRadius: 40))
        .background {
            RoundedRectangle(cornerRadius: 40)
                .stroke(lineWidth: 1)
                .fill(.white)
                .opacity(0.4)
        }
        .offset(state ? .zero : CGSize(width: 0, height: -45))
        .offset(dragOffset)
        .opacity(state ? 1 : 0)
        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: -50)))
        .gesture(
            DragGesture()
                .updating(self.$dragOffset, body: { (value, state, _) in
                    if value.translation.height < 0 {
                        state = CGSize(width: .zero, height: value.translation.height / 2)
                    } else if value.translation.height > 0 {
                        state = CGSize(width: .zero, height: value.translation.height / 8)
                    }
                })
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                            state = false
                            teamVM.removeMyNotificationToFirestore(team: teamVM.team, data: element)
                        }
                    }
                }
        )
        .animation(.interpolatingSpring(mass           : 0.8,
                                        stiffness      : 100,
                                        damping        : 80,
                                        initialVelocity: 0.1),
                                        value          : dragOffset)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + loadWaitTime) {
                withAnimation(.easeOut(duration: 0.5)) { state = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + element.exitTime + loadWaitTime) {
                withAnimation {
                    switch element.type {
                    case .addItem, .updateItem, .commerce:
                        removeNotificationController(type: .all)
                    case .join:
                        removeNotificationController(type: .local)
                    }
                }
            }
        }
    }
    func removeNotificationController(type: RemoveType) {
        switch type {
        case .local:
            withAnimation {
                state = false
                vm.currentNotification = nil
                teamVM.removeMyNotificationToFirestore(team: teamVM.team, data: element)
            }
        case .all:
            withAnimation {
                state = false
                vm.currentNotification = nil
                teamVM.removeAllMemberNotificationToFirestore(team: teamVM.team, data: element)
            }
        }
    }
}

/// 通知機能における通知タイプを管理する列挙体。
enum NotificationType: Codable, Equatable {
    case addItem(Item)
    case updateItem(Item)
    case commerce([Item])
    case join(User)

    var type: NotificationType {
        return self
    }

    /// 通知に渡すメッセージテキスト。
    var message: String {
        switch self {
        case .addItem(let item):
            let name = item.name.isEmpty ? "No Name" : item.name
            return "\(name) がチームアイテムに追加されました。"
        case .updateItem(let item):
            let name = item.name.isEmpty ? "No Name" : item.name
            return "\(name) のアイテム情報が更新されました。"
        case .commerce(let items):
            let firstItemName = items.first?.name ?? ""
            var message: String {
                if items.count > 1 {
                    return "\(firstItemName) 他、\(items.count - 1)個のアイテム情報が更新されました。"
                } else {
                    return "\(firstItemName) のアイテム情報が更新されました。"
                }
            }
            return message
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
        case .commerce(let items):
            return items.first?.photoURL
        case .join(let user):
            return user.iconURL
        }
    }
    var symbol: String {
        switch self {
        case .addItem, .updateItem:
            return "shippingbox.fill"
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
        case .commerce:
            return Color.mint
        }
    }
    /// 通知が画面上に残る時間
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
    static var frame = NotificationType.commerce(sampleItems)
    static var previews: some View {
        VStack {
            IconAndMessageView(element: TeamNotifyFrame(type: frame.type, message: frame.message, exitTime: 10))
        }
    }
}
