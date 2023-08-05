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
                    NotificationContainer(element: element)
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
/// 受け取った通知フレームから通知のタイプを参照して、タイプに合わせた出力を行う。
fileprivate struct NotificationContainer: View {

    ///
    fileprivate enum RemoveType {
        case local, all
    }
    /// 通知の種類データと、種類ごとの要素データをもつ
    let element: TeamNotifyFrame

    @EnvironmentObject var vm: TeamNotificationViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @Environment(\.colorScheme) var colorScheme

    @State private var state: Bool = false
    @State private var detail: Bool = false
    @State private var selectedIndex: Int = 0
    @State private var count: Int = 0
    @GestureState var dragOffset: CGSize = .zero
    @Namespace var animation
    /// 通知アイコンWebImageの画像ロード完了を待つ時間。出現時のアニメーション不具合を防ぐため。
    let loadWaitTime: CGFloat = 0.5
    let screen = UIScreen.main.bounds
    let stateTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    /// データ更新内容の取り消しを管理するプロパティ群
    @State private var cancelState: Bool = false
    @State private var longPressButtonFrame: CGFloat = .zero
    let cancelButtonFrame: CGFloat = 80
    let longPressMinTime: CGFloat = 1.0
    let cancelTimer = Timer.publish(every: 0.01, on: .current, in: .common) .autoconnect()

    var body: some View {
        let backColor = colorScheme == .dark ? Color.black : Color.white
        let shadowColor = colorScheme == .dark ? Color.white : Color.black

        VStack {
            /// 通知ボードのヘッドビュー
            HStack {
                CircleIconView(url: element.imageURL, size: 60)

                Text(element.message)
                    .tracking(1)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.7)
                    .padding(.horizontal, 10)
            }
            /// 通知ボードの詳細ビュー
            if detail {
                Text("--- 詳細 ---")
                    .tracking(4)
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundColor(.gray.opacity(0.6))

                switch element.type {
                case .addItem(let item):
                    CreateItemDetail(item: item)

                case .updateItem(let item):
                    UpdateItemDetail(item: item)

                case .commerce(let commerceItems):
                    CommerceItemDetail(item: commerceItems[selectedIndex],
                                       count: commerceItems.count)

                case .join(let user):
                    EmptyView()
                }

                Label("取消", systemImage: "clock.arrow.circlepath")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(cancelState ? .gray : .white)
                    .padding(5)
                    .frame(width: cancelButtonFrame)
                /// ボタン長押しで変動する背景フレーム
                /// 規定時間まで長押しが続くと、対象データの変更内容が取り消される
                    .background(
                        HStack {
                            Capsule().fill(.red)
                                .frame(width: cancelState ? longPressButtonFrame : cancelButtonFrame)
                            Spacer().frame(minWidth: 0)
                        }
                    )
                    .background(Capsule().fill(.gray.opacity(0.6)))
                    .scaleEffect(cancelState ? 1 + (longPressButtonFrame / 250) : 1)
                    .onLongPressGesture(
                        minimumDuration: longPressMinTime, // プレス完了の時間設定
                        pressing: { pressing in
                            if pressing {
                                // 更新データの取り消し判定開始
                                cancelState = true
                            } else {
                                // 取り消し中断
                                cancelState = false
                            }
                        },
                        perform: {
                            // 取り消し処理実行
                            cancelState = false
                        })
                    .onReceive(cancelTimer) { value in
                        if !cancelState {
                            longPressButtonFrame = 0
                        } else {
                            // Timerの更新頻度が0.01のため、100で割る
                            longPressButtonFrame += (cancelButtonFrame / 100)
                        }
                    }
            } // if detail
        }
        .frame(width: screen.width * 0.9)
        .padding(10)
        .background(
            backColor.shadow(.drop(color: shadowColor.opacity(0.25),radius: 10)),
                    in: RoundedRectangle(cornerRadius: 40))
        .background {
            RoundedRectangle(cornerRadius: 40)
                .stroke(lineWidth: 1)
                .fill(.white)
                .opacity(0.4)
        }
        .opacity(state ? 1 : 0)
        .offset(state ? .zero : CGSize(width: 0, height: -85))
        .offset(dragOffset)
        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: -40)))
        .onTapGesture {
            withAnimation(.spring(response: 0.4, blendDuration: 1)) { detail.toggle() }
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
            // WebImageの画像ロード完了を待つため、表示までに少しタイムラグを持たせている。
            DispatchQueue.main.asyncAfter(deadline: .now() + loadWaitTime) {
                withAnimation(.easeOut(duration: 0.5)) { state = true }
            }
        }
        /// 通知ボードの自動破棄に用いるタイムカウントレシーバー。
        .onReceive(stateTimer) { _ in
            if dragOffset != .zero || detail {
                count = 0
            } else {
                count += 1
                if count > Int(element.exitTime) {
                    print("通知ボードの破棄時間です")
                    withAnimation(.easeIn(duration: 0.3)) {
                        self.removeNotificationController(type: element.type)
                    }
                }
            }
        }
    }
    @ViewBuilder
    func CircleIconView(url: URL?, size: CGFloat) -> some View {
        if let url {
            WebImage(url: url)
                .resizable().scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .shadow(radius: 1)
        } else {
            Image(systemName: element.type.symbol)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Circle().fill(.gray.gradient))
                .shadow(radius: 1)
        }
    }
    @ViewBuilder
    func RectIconView(url: URL?, size: CGFloat) -> some View {
        if let url = url {
            WebImage(url: url)
                .resizable().scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 1)
        } else {
            Image(systemName: "cube.transparent.fill")
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(RoundedRectangle(cornerRadius: 5).fill(.gray.gradient))
                .shadow(radius: 1)
        }
    }
    @ViewBuilder
    /// 通知の詳細部分に表示するアイテムの名前とアイコン
    func ItemDetailIconAndName(item: Item, size iconSize: CGFloat) -> some View {
        HStack(spacing: 20) {
            RectIconView(url: item.photoURL, size: iconSize)
            VStack(alignment: .leading, spacing: 10) {
                Text("\(item.tag):").font(.footnote).opacity(0.5)
                CustomOneLineLimitText(text: item.name, limit: 15)
                    .fontWeight(.bold)
            }
        }
    }
    /// 主にデータ追加時の通知詳細セクションに用いるグリッドひとつ分のグリッドビュー要素。
    /// 「<データ名> : <データバリュー>」の形でGridRowを返す。
    /// グリッドの整列制御は親のGrid側で操作する。
    @ViewBuilder
    func AddElementGridRow(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title)
            Text(":")
            Text(value)
        }
        .font(.callout)
        .opacity(0.6)
    }
    /// 更新が発生したデータの更新内容を、比較で表示するためのグリッドビュー要素。
    /// 「<データ名> : <更新前バリュー> ▶︎ <更新後バリュー>」の形でGridRowを返す。
    /// グリッドの整列制御は親のGrid側で操作する。
    @ViewBuilder
    func UpdateElementGridRow(_ title: String, _ before: String, _ after: String) -> some View {
        GridRow {
            Text(title)
            Text(":")
            Text(before)
            Text("▶︎")
            Text(after)
        }
        .font(.callout)
        .opacity(0.6)
    }
    @ViewBuilder
    func CreateItemDetail(item: Item) -> some View {
        Grid(alignment: .leading, verticalSpacing: 20) {

            ItemDetailIconAndName(item: item, size: 50)
            Divider()
            AddElementGridRow("製作者", item.author.isEmpty ? "???" : item.author)
            Divider()
            AddElementGridRow("在庫", String(item.inventory))
            Divider()
        } // Grid
        .padding()
        .padding(.horizontal, 30) // 一要素の詳細しか表示しないため、横幅を狭くする

    }
    @ViewBuilder
    func UpdateItemDetail(item: CompareItem) -> some View {
        Grid(alignment: .leading, verticalSpacing: 20) {

            ItemDetailIconAndName(item: item.after, size: 50)
            Divider()

            if item.before.tag != item.after.tag {
                UpdateElementGridRow("タグ",
                               item.before.tag,
                               item.after.tag)
                Divider()
            }
            if item.before.name != item.after.name {
                UpdateElementGridRow("名前",
                               item.before.name,
                               item.after.name)
                Divider()
            }

            if item.before.author != item.after.author {
                UpdateElementGridRow("製作者",
                               item.before.author,
                               item.after.author)
                Divider()
            }

            if item.before.inventory != item.after.inventory {
                UpdateElementGridRow("在庫",
                               String(item.before.inventory),
                               String(item.after.inventory))
                Divider()
            }
            if item.before.cost != item.after.cost {
                UpdateElementGridRow("原価",
                               String(item.before.cost),
                               String(item.after.cost))
                Divider()
            }
            if item.before.sales != item.after.sales {
                UpdateElementGridRow("売り上げ",
                               String(item.before.sales),
                               String(item.after.sales))
                Divider()
            }

            if item.before.totalAmount != item.after.totalAmount {
                UpdateElementGridRow("総売個数",
                               String(item.before.totalAmount),
                               String(item.after.totalAmount))
                Divider()
            }

            if item.before.totalInventory != item.after.totalInventory {
                UpdateElementGridRow("総仕入れ",
                               String(item.before.totalInventory),
                               String(item.after.totalInventory))
                Divider()
            }
        } // Grid
        .padding()

    }
    @ViewBuilder
    func CommerceItemDetail(item: CompareItem, count commerceItemsCount: Int) -> some View {
        VStack {
            if commerceItemsCount > 1 {
                CommerceItemsTableNumber(count: commerceItemsCount)
            }

            Grid(alignment: .leading, verticalSpacing: 20) {
                ItemDetailIconAndName(item: item.after, size: 50)
                Divider()
                UpdateElementGridRow("在庫",
                               String(item.before.inventory),
                               String(item.after.inventory))
                Divider()

                if item.before.sales != item.after.sales {
                    UpdateElementGridRow("売り上げ",
                                   String(item.before.sales),
                                   String(item.after.sales))
                    Divider()
                }
            } // Grid
            .padding()
        } // VStack
    }
    /// カートアイテムが複数あった場合に、各アイテム情報を切り替えるための番号テーブル。
    @ViewBuilder
    func CommerceItemsTableNumber(count itemsCount: Int) -> some View {
        let backColor = colorScheme == .dark ? Color.black : Color.white
        let shadowColor = colorScheme == .dark ? Color.white : Color.black
        HStack {
            ForEach(0..<itemsCount, id: \.self) { itemIndex in
                Text("\(itemIndex + 1)")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .opacity(itemIndex == selectedIndex ? 1 : 0.3)
                    .overlay {
                        if itemIndex != selectedIndex {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray)
                                .opacity(0.2)
                        }
                    }
                    .background(
                        backColor
                            .shadow(.drop(color: shadowColor.opacity(0.2),radius: 3)),
                                in: RoundedRectangle(cornerRadius: 10)
                    )
                    .onTapGesture { selectedIndex = itemIndex }
            }
        }
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
    case updateItem(CompareItem)
    case commerce([CompareItem])
    case join(User)

    var type: TeamNotificationType {
        return self
    }

    /// 通知に渡すメッセージテキスト。
    var message: String {
        switch self {
        case .addItem:
            return "新しいアイテムが追加されました。"
        case .updateItem:
            return "アイテム情報が更新されました。"
        case .commerce(let items):
            return "カート内 \(items.count) 個のアイテムが精算されました。"
        case .join(let user):
            return "\(user.name) さんがチームに参加しました！"
        }
    }
    /// 通知アイコンに用いられる画像URL。WebImageによって表示される。
    var imageURL: URL? {
        switch self {
        case .addItem(let item):
            return item.photoURL
        case .updateItem(let item):
            return item.after.photoURL
        case .commerce(let items):
            return items.first?.after.photoURL
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
                                       type: .addItem(sampleItems.first!),
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
