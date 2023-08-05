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

    var body: some View {
        VStack {
            if let element = vm.currentNotification {
                switch element.type {
                case .addItem, .updateItem, .join, .commerce:
                    IconAndMessageBoard(element: element)
                }
            }
            Spacer()
        } // VStack
        .onChange(of: vm.myNotifications) { remainingValue in
            if remainingValue.isEmpty {
                print("残りの通知の数: 0個")
                return
            } else {
                print("残りの通知の数: \(remainingValue.count)個")
                guard let element = remainingValue.first else { return }
                vm.currentNotification = element
            }
        }
        .onAppear {
            if vm.myNotifications.isEmpty {
                print("通知の数: 0個")
                return
            } else {
                print("通知の追加を検知")
                print("通知の数: \(vm.myNotifications.count)個")
                guard let element = vm.myNotifications.first else { return }
                vm.currentNotification = element
            }
        }
    }
}

/// アイコン+メッセージ型の通知ボード。
/// WebImageの画像ロード完了を待つため、表示までに少しタイムラグを持たせている。
fileprivate struct IconAndMessageBoard: View {

    fileprivate enum RemoveType {
        case local, all
    }
    /// 表示される通知ボードの要素データ
    let element: TeamNotifyFrame

    @EnvironmentObject var vm: TeamNotificationViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var state: Bool = false
    @State private var detail: Bool = false
    @State private var selectedIndex: Int = 0
    @State private var count: Int = 0
    @GestureState var dragOffset: CGSize = .zero
    /// WebImageの画像ロード完了を待つ時間。出現時のアニメーション不具合を防ぐため。
    let loadWaitTime: CGFloat = 0.5
    let screen = UIScreen.main.bounds
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var body: some View {
        let backColor = colorScheme == .dark ? Color.black : Color.white

        VStack {
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
            /// detailプロパティがtrueだったら表示される詳細
            if detail {
                switch element.type {
                case .addItem(let item):
                    UpdateItemDetail(item, item)

                case .updateItem(let item):
                    UpdateItemDetail(item, item)

                case .commerce(let cartItems):
                    VStack {
                        HStack {
                            ForEach(cartItems.indices) { itemIndex in
                                Text("\(itemIndex + 1)")
                                    .frame(maxWidth: .infinity, maxHeight: 30)
                                    .background {
                                        if itemIndex == selectedIndex {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.gray.opacity(0.1))
                                        }
                                    }
                                    .background(
                                        backColor
                                            .shadow(.drop(color: .black.opacity(0.5),radius: 1)),
                                                in: RoundedRectangle(cornerRadius: 10)
                                    )
                                    .onTapGesture(perform: {
                                        selectedIndex = itemIndex
                                    })
                            }
                        }
                        UpdateItemDetail(cartItems[selectedIndex],
                                         cartItems[selectedIndex])
                    }

                case .join(let user):
                    EmptyView()
                }
            }
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
        .opacity(state ? 1 : 0)
        .offset(state ? .zero : CGSize(width: 0, height: -45))
        .offset(dragOffset)
        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: -40)))
        .onTapGesture {
            withAnimation(.spring(response: 0.5, blendDuration: 1)) { detail.toggle() }
        }
        .gesture(
            DragGesture()
                .updating(self.$dragOffset, body: { (value, state, _) in
                    if value.translation.height < 0 {
                        state = CGSize(width: .zero, height: value.translation.height / 4)
                    } else if value.translation.height > 0 {
                        state = CGSize(width: .zero, height: value.translation.height / 8)
                    }
                })
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation(.spring(response: 0.4)) {
                            self.removeNotificationController(type: element.type)
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
        }
        .onChange(of: count) { _ in
            if count > Int(element.exitTime) {
                print("通知ボードの破棄時間です")
                withAnimation(.easeIn(duration: 0.3)) {
                    self.removeNotificationController(type: element.type)
                }
            }
        }
        /// 通知ボードの破棄タイミングに使うタイムカウント。
        .onReceive(timer) { _ in
            if dragOffset != .zero || detail {
                count = 0
            } else {
                count += 1
            }
        }
    }
    @ViewBuilder
    func UpdateItemDetail(_ before: Item, _ after: Item) -> some View {
        Grid(alignment: .leading, verticalSpacing: 20) {
            Divider()
            GridRow {
                Text("名前:")
                Text("サンプル１")
                Text("▶︎")
                Text("サンプル２")
            }
            Divider()
            GridRow {
                Text("売り上げ:")
                Text("10000")
                Text("▶︎")
                Text("12000")
            }
        }
        .opacity(0.7)
        .padding()
    }
    /// 表示通知の破棄と、表示済み通知の取り扱いをコントロールするメソッド。
    /// 通知タイプによって、ローカル削除か全体削除かを分岐する。
    /// 削除要素のアニメーションは実行元で調整する。
    fileprivate func removeNotificationController(type: TeamNotificationType) {
        switch type {
        case .addItem, .updateItem, .commerce:
            vm.currentNotification = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                vm.removeAllMemberNotificationToFirestore(team: teamVM.team, data: element)
            }
        case .join:
            vm.currentNotification = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                vm.removeMyNotificationToFirestore(team: teamVM.team, data: element)
            }
        }
    }
}

/// 通知機能における通知タイプを管理する列挙体。
enum TeamNotificationType: Codable, Equatable {
    case addItem(Item)
    case updateItem(Item)
    case commerce([Item])
    case join(User)

    var type: TeamNotificationType {
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
                    return "\(firstItemName) 他、\(items.count - 1)個のカート内アイテムが精算されました。"
                } else {
                    return "カート内の\(firstItemName) が精算されました。"
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
    static var notifyVM = TeamNotificationViewModel()
    static var teamVM = TeamViewModel()
    static var frame = TeamNotifyFrame(id: UUID(),
                                       type: .commerce(sampleItems),
                                       message: "これは通知メッセージのチェックです。",
                                       imageURL: sampleItems.first!.photoURL,
                                       exitTime: 3.0)
    static var previews: some View {
        ZStack {
            TeamNotificationView()
            Button("通知を確認") {
                notifyVM.myNotifications.append(frame)
            }
        }
        .environmentObject(notifyVM)
        .environmentObject(teamVM)
    }
}
