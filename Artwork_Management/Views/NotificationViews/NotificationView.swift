//
//  NotificationBoard.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

/// チームのメンバー全員に届く通知TeamNotificationを画面に表示するビュー。
/// ビューモデルの通知保持プロパティ「myNotifications」に値が検知されることで、
/// 表示 -> 破棄 -> 取得 のループが通知が無くなるまで続く。
struct NotificationView: View {

    @EnvironmentObject var vm: NotificationViewModel

    var body: some View {
        VStack {
            if let element = vm.currentNotification {
                NotificationContainer(element: element)
            }
            Spacer()
        }
    }
}

/// アイコン+メッセージ型の通知ボード。
/// 受け取った通知フレームから通知のタイプを参照して、タイプに合わせた出力を行う。
fileprivate struct NotificationContainer: View {

    /// 通知のタイプと、タイプごとのデータ要素をもつ通知一個分のエレメント。
    let element: Log

    @EnvironmentObject var vm: NotificationViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @Environment(\.colorScheme) var colorScheme

    /// 通知ボードの表示有無を管理するプロパティ。
    /// WebImageのロードを待つため、onAppear内で少しタイムラグを持たせてからtrueにしている。
    @State private var showState: Bool = false
    /// 通知ボードの詳細表示を管理するプロパティ。
    @State private var detail: Bool = false
    /// カート精算された複数のアイテムの中で、現在通知ボード上に選択表示されているアイテムのインデックス。
    @State private var showIndex: Int = 0
    /// タイマーパブリッシャーによって更新されるカウントプロパティ。
    @State private var showLimitCount: Int = 0

    @GestureState var dragOffset: CGSize = .zero
    @Namespace var animation
    /// 通知アイコンWebImageの画像ロード完了を待つ時間。出現時のアニメーション不具合を防ぐため。
    let loadWaitTime: CGFloat = 0.5
    let screen = UIScreen.main.bounds
    /// １秒ごとにカウントをプラスしていくタイマーパブリッシャー。自動破棄を管理するために用いる。
    let showLimitTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    /// キャンセルボタンによって更新キャンセルされたデータの「createTime」が格納されるプロパティ。
    /// このcreateTime値を照らし合わせて、表示データがキャンセル実行済みかどうかを判定する。
    @State private var resetedLogs: [Date] = []

    var reseted: Bool {
        return checkReseted(element: element)
    }

    var body: some View {
        let backColor = colorScheme == .dark ? Color.black : Color.white
        let shadowColor = colorScheme == .dark ? Color.white : Color.black

        VStack {
            /// 通知ボードのヘッドビュー
            HStack {
                CircleIconView(url: element.type.imageURL, size: 60)

                Text(element.type.message)
                    .tracking(1)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.7)
                    .padding(.horizontal, 10)
            }

            if detail {
                Text("--- 詳細 ---")
                    .tracking(4)
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundColor(.gray.opacity(0.6))

                /// 通知ボードのタイプ別詳細ビュー
                switch element.type {

                case .addItem(let item):
                    AddItemDetail(item: item)
                    ResetLogButton(element: element, reseted: reseted)

                case .updateItem(let item):
                    UpdateItemDetail(item: item)
                    ResetLogButton(element: element, reseted: reseted)

                case .deleteItem(let item):
                    DeletedItemDetail(item: item)
                    ResetLogButton(element: element, reseted: reseted)

                case .commerce(let items):
                    CommerceItemDetail(items: items)
                    ResetLogButton(element: element, reseted: reseted)

                case .join(let user):
                    EmptyView()

                case .updateUser(let user):
                    UpdateUserDetail(user: user)
                    ResetLogButton(element: element, reseted: reseted)

                case .updateTeam(let team):
                    UpdateTeamDetail(team: team)
                    ResetLogButton(element: element, reseted: reseted)
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
        .opacity(showState ? 1 : 0)
        .offset(showState ? .zero : CGSize(width: 0, height: -85))
        .offset(dragOffset)
        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: -80)))
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
                            vm.currentNotification = nil
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            vm.setRead(team: teamVM.team, element: element)
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
                withAnimation(.easeOut(duration: 0.5)) { showState = true }
            }
        }
        /// 通知ボードの自動破棄に用いるタイムカウントレシーバー。
        .onReceive(showLimitTimer) { _ in
            if dragOffset != .zero || detail {
                showLimitCount = 0
            } else {
                showLimitCount += 1
                if showLimitCount > Int(element.type.stayTime) {
                    print("通知ボードの破棄時間です")
                    withAnimation(.easeIn(duration: 0.3)) {
                        vm.currentNotification = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        vm.setRead(team: teamVM.team, element: element)
                        vm.deleteBeforeUIImageController(element: element)
                    }
                }
            }
        }
    }
    // 🍎------  アイテム通知の詳細ビュー   -------🍎
    @ViewBuilder
    func DetailTopToItem(item: Item, size iconSize: CGFloat) -> some View {
        HStack(spacing: 20) {
            RectIconView(url: item.photoURL, size: iconSize)
            VStack(alignment: .leading, spacing: 10) {
                Text("\(item.tag):").font(.footnote).opacity(0.5)
                CustomOneLineLimitText(text: item.name, limit: 15)
                    .fontWeight(.bold)
            }
        }
    }
    @ViewBuilder
    func AddItemDetail(item: Item) -> some View {
        /// 表示アイテムが更新キャンセルされているかを判定する

        VStack(spacing: 10) {

            DetailTopToItem(item: item, size: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)

            VStack {
                Grid(alignment: .leading, verticalSpacing: 20) {
                    Divider()
                    SingleNumberGridRow("製作者", item.author.isEmpty ? "???" : item.author)
                    Divider()
                    SingleNumberGridRow("在庫", String(item.inventory))
                    Divider()
                    SingleNumberGridRow("価格", item.price != 0 ? String(item.price) : "-")
                    Divider()
                } // Grid
                .padding()
                .padding(.horizontal, 30) // 表示要素１つのため、横幅を狭くする
            }
        } // VStack(Detail全体)
        .opacity(reseted ? 0.4 : 1)
        .overlay {
            if reseted {
                ResetedStumpView(color: .red)
            }
        }
    }
    @ViewBuilder
    func UpdateItemDetail(item: CompareItem) -> some View {

        VStack(spacing: 10) {

            DetailTopToItem(item: item.after, size: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)

            VStack {
                Grid(alignment: .leading, verticalSpacing: 20) {

                    Divider()

                    if item.before.photoURL != item.after.photoURL {
                        CompareRectImageGridRow("アイコン",
                                                item.before.photoURL,
                                                item.after.photoURL,
                                                size: 40)
                        Divider()
                    }

                    if item.before.tag != item.after.tag {
                        CompareTextGridRow("タグ",
                                           item.before.tag,
                                           item.after.tag)
                        Divider()
                    }
                    if item.before.name != item.after.name {
                        CompareTextGridRow("名前",
                                           item.before.name,
                                           item.after.name)
                        Divider()
                    }

                    if item.before.author != item.after.author {
                        CompareTextGridRow("製作者",
                                           item.before.author,
                                           item.after.author)
                        Divider()
                    }

                    if item.before.inventory != item.after.inventory {
                        CompareNumberGridRow("在庫",
                                              String(item.before.inventory),
                                              String(item.after.inventory))
                        Divider()
                    }
                    if item.before.cost != item.after.cost {
                        CompareNumberGridRow("原価",
                                              String(item.before.cost),
                                              String(item.after.cost))
                        Divider()
                    }
                    if item.before.sales != item.after.sales {
                        CompareNumberGridRow("売り上げ",
                                              String(item.before.sales),
                                              String(item.after.sales))
                        Divider()
                    }

                    if item.before.totalAmount != item.after.totalAmount {
                        CompareNumberGridRow("総売個数",
                                              String(item.before.totalAmount),
                                              String(item.after.totalAmount))
                        Divider()
                    }

                    if item.before.totalInventory != item.after.totalInventory {
                        CompareNumberGridRow("総仕入れ",
                                              String(item.before.totalInventory),
                                              String(item.after.totalInventory))
                        Divider()
                    }
                } // Grid
                .opacity(reseted ? 0.4 : 1)
                .padding()
            }
            .overlay {
                if reseted {
                    ResetedStumpView(color: .red)
                }
            }
        } // VStack
    }
    @ViewBuilder
    func DeletedItemDetail(item: Item) -> some View {

        VStack(spacing: 10) {
            DetailTopToItem(item: item, size: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)

            VStack {
                Grid(alignment: .leading, verticalSpacing: 20) {
                    Divider()
                    SingleTextGridRow("製作者", item.author.isEmpty ? "???" : item.author)
                    Divider()
                    SingleNumberGridRow("在庫", String(item.inventory))
                    Divider()
                    SingleNumberGridRow("価格", item.price != 0 ? String(item.price) : "-")
                    Divider()
                } // Grid
                .padding()
                .padding(.horizontal, 30) // 表示要素１つのため、横幅を狭くする
            }
        }
        .opacity(reseted ? 0.4 : 1)
        .overlay {
            if reseted {
                ResetedStumpView(color: .white)
            }
        }
    }
    @ViewBuilder
    func CommerceItemDetail(items: [CompareItem]) -> some View {

        VStack(spacing: 10) {
            if items.count > 1 {
                CommerceItemsTableNumber(count: items.count)
            }
            DetailTopToItem(item: items[showIndex].after, size: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)

            VStack {
                Grid(alignment: .leading, verticalSpacing: 20) {

                    Divider()
                    CompareNumberGridRow("在庫",
                                         String(items[showIndex].before.inventory),
                                         String(items[showIndex].after.inventory))
                    Divider()

                    if items[showIndex].before.sales != items[showIndex].after.sales {
                        CompareNumberGridRow("売り上げ",
                                             String(items[showIndex].before.sales),
                                             String(items[showIndex].after.sales))
                        Divider()
                    }
                } // Grid
                .opacity(reseted ? 0.4 : 1)
                .padding()
            }
            .overlay {
                if reseted {
                    ResetedStumpView(color: .red)
                }
            }
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
                    .opacity(itemIndex == showIndex ? 1 : 0.3)
                    .overlay {
                        if itemIndex != showIndex {
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
                    .onTapGesture { showIndex = itemIndex }
            }
        }
    }

    // 🍎------  ユーザー通知の詳細ビュー   -------🍎
    /// チームに関する通知の詳細表示で用いる詳細ビューのトップ部分。
    @ViewBuilder
    func DetailTopToUser(user: User, size iconSize: CGFloat) -> some View {
        HStack(spacing: 20) {
            CircleIconView(url: user.iconURL, size: iconSize)
            CustomOneLineLimitText(text: user.name, limit: 15)
                .fontWeight(.bold)
        }
    }
    @ViewBuilder
    func UpdateUserDetail(user: CompareUser) -> some View {
        /// 表示アイテムが更新キャンセルされているかを判定する
        var reseted: Bool {
            return resetedLogs.contains(user.after.createTime)
        }

        VStack(spacing: 10) {
            DetailTopToUser(user: user.after, size: 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)

            VStack {
                Grid(alignment: .leading, verticalSpacing: 20) {
                    Divider()
                    if user.before.iconURL != user.after.iconURL {
                        CompareCircleImageGridRow("アイコン",
                                                user.before.iconURL,
                                                user.after.iconURL,
                                                size: 40)
                        Divider()
                    }
                    if user.before.name != user.after.name {
                        CompareTextGridRow("名前",
                                           user.before.name,
                                           user.after.name)
                        Divider()
                    }
                } // Grid
                .padding()
            }
            .opacity(reseted ? 0.4 : 1)
            .overlay {
                if reseted {
                    ResetedStumpView(color: .red)
                }
            }
        }
    }

    // 🍎------  チーム通知の詳細ビュー   -------🍎
    @ViewBuilder
    func DetailTopToTeam(team: Team, size iconSize: CGFloat) -> some View {
        HStack(spacing: 20) {
            CircleIconView(url: team.iconURL, size: iconSize)
            CustomOneLineLimitText(text: team.name, limit: 15)
                .fontWeight(.bold)
        }
    }
    @ViewBuilder
    func UpdateTeamDetail(team: CompareTeam) -> some View {
        /// 表示アイテムが更新キャンセルされているかを判定する
        var reseted: Bool {
            return resetedLogs.contains(team.after.createTime)
        }

        VStack(spacing: 10) {
            DetailTopToTeam(team: team.after, size: 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top)

            VStack {
                Grid(alignment: .leading, verticalSpacing: 20) {
                    Divider()
                    if team.before.iconURL != team.after.iconURL {
                        CompareCircleImageGridRow("アイコン",
                                                team.before.iconURL,
                                                team.after.iconURL,
                                                size: 40)
                        Divider()
                    }
                    if team.before.name != team.after.name {
                        CompareTextGridRow("名前",
                                           team.before.name,
                                           team.after.name)
                        Divider()
                    }
                } // Grid
                .padding()
            }
            .opacity(reseted ? 0.4 : 1)
            .overlay {
                if reseted {
                    ResetedStumpView(color: .red)
                }
            }
        }
    }

    // 🍎------  ビューパーツ類   -------🍎
    /// 主にデータ追加時の通知詳細セクションに用いるグリッドひとつ分のグリッドビュー要素。
    /// 「<データ名> : <データバリュー>」の形でGridRowを返す。
    /// グリッドの整列制御は親のGrid側で操作する。
    @ViewBuilder
    func SingleNumberGridRow(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title)
            Text(":")
            Text(value)
        }
        .lineLimit(1)
        .font(.callout)
        .fontWeight(.bold)
        .opacity(0.7)
    }
    @ViewBuilder
    func SingleTextGridRow(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title)
            Text(":")
            Text(value).font(.caption)
        }
        .lineLimit(1)
        .font(.callout)
        .fontWeight(.bold)
        .opacity(0.7)
    }
    /// 更新が発生したデータの更新内容を、比較で表示するためのグリッドビュー要素。
    /// 「<データ名> : <更新前バリュー> ▶︎ <更新後バリュー>」の形でGridRowを返す。
    @ViewBuilder
    func CompareNumberGridRow(_ title: String, _ before: String, _ after: String) -> some View {
        GridRow {
            Text(title)
            Text(":")
            Text(before)
            Text("▶︎")
            Text(after)
        }
        .lineLimit(1)
        .font(.callout)
        .fontWeight(.bold)
        .opacity(0.7)
    }
    @ViewBuilder
    func CompareTextGridRow(_ title: String, _ before: String, _ after: String) -> some View {
        GridRow {
            Text(title)
            Text(":")
            Text(before).font(.caption)
            Text("▶︎")
            Text(after).font(.caption)
        }
        .lineLimit(1)
        .font(.callout)
        .fontWeight(.bold)
        .opacity(0.7)
    }
    @ViewBuilder
    func CompareCircleImageGridRow(_ title: String, _ before: URL?, _ after: URL?, size: CGFloat) -> some View {
        GridRow {
            Text(title).opacity(0.7)
            Text(":").opacity(0.7)
            CircleIconView(url: before, size: size)
            Text("▶︎").opacity(0.7)
            CircleIconView(url: after, size: size)
        }
        .font(.callout)
        .fontWeight(.bold)
    }
    @ViewBuilder
    func CompareRectImageGridRow(_ title: String, _ before: URL?, _ after: URL?, size: CGFloat) -> some View {
        GridRow {
            Text(title).opacity(0.7)
            Text(":").opacity(0.7)
            RectIconView(url: before, size: size)
            Text("▶︎").opacity(0.7)
            RectIconView(url: after, size: size)
        }
        .font(.callout)
        .fontWeight(.bold)
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
            Circle().fill(.gray.gradient)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: element.type.symbol)
                        .foregroundColor(.white)
                        .frame(width: size * 0.6, height: size * 0.6)
                }
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
            RoundedRectangle(cornerRadius: 5)
                .fill(.gray.gradient)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: "cube.transparent.fill")
                        .resizable().scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: size * 0.6, height: size * 0.6)
                }
                .shadow(radius: 1)
        }
    }
    @ViewBuilder
    func ResetedStumpView(color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
                .frame(width: 180, height: 40)
            Text("Canceled")
                .tracking(5)
                .fontWeight(.black)
        }
        .opacity(0.7)
        .foregroundColor(color)
        .rotationEffect(Angle(degrees: -10))
    }
    /// ログデータのcanceledDatasDateを検索し、更新内容がキャンセル済みかどうかをBool値で返す
    func checkReseted(element: Log) -> Bool {
        switch element.type {
        case .addItem(let item):
            return element.canceledDatas.contains(item.createTime)

        case .updateItem(let item):
            return element.canceledDatas.contains(item.before.createTime)

        case .deleteItem(let item):
            return element.canceledDatas.contains(item.createTime)

        case .commerce(let items):
            return element.canceledDatas.contains(items[showIndex].before.createTime)

        case .join(let user):
            return element.canceledDatas.contains(user.createTime)

        case .updateUser(let user):
            return element.canceledDatas.contains(user.before.createTime)

        case .updateTeam(let team):
            return element.canceledDatas.contains(team.before.createTime)
        }
    }
}

/// 通知から受け取ったデータ更新内容を取り消す長押し実行型のカスタムボタン。
/// 取り消し対象データの更新前の値と、取り消し完了済みのステートを管理するためのid配列参照を受け取る
/// 取り消しが完了したら、対象データのcreateTimeをキャンセル判定配列に入れる
fileprivate
struct ResetLogButton: View {

    @EnvironmentObject var vm: NotificationViewModel
    @EnvironmentObject var teamVM: TeamViewModel

    let element: Log
    let reseted: Bool

    let pressingMinTime: CGFloat = 1.0 // 取り消し実行に必要な長押しタイム設定
    let pressingTimer = Timer.publish(every: 0.01, on: .current, in: .common) .autoconnect()

    @State private var pressingState: Bool = false
    @State private var pressingFrame: CGFloat = .zero
    @State private var resetExecution: Bool?
    var body: some View {
        // ボタンのサイズ
        let cancelButtonFrame: CGFloat = self.reseted ? 100 : 80

        Label(reseted ? "取消済み" : "取消", systemImage: "clock.arrow.circlepath")
            .font(.footnote)
            .fontWeight(.bold)
            .foregroundColor(pressingState ? .gray : .white)
            .padding(5)
            .frame(width: cancelButtonFrame)
        /// ボタン長押しで変動する背景フレーム
        /// 規定時間まで長押しが続くと、対象データの変更内容が取り消される
            .background(
                HStack {
                    Capsule()
                        .fill(reseted ? .gray : .red)
                        .frame(width: pressingState ? pressingFrame : cancelButtonFrame)
                    Spacer().frame(minWidth: 0)
                }
            )
            .background(Capsule().fill(.gray.opacity(0.6)))
            .scaleEffect(pressingState ? 1 + (pressingFrame / 250) : 1)
            .opacity(reseted ? 0.4 : 1)
            .onLongPressGesture(
                minimumDuration: pressingMinTime,
                pressing: { pressing in
                    if pressing {
                        if reseted { return } // 取消済み
                        // 更新データの取り消し判定開始
                        pressingState = true
                    } else {
                        // 取り消し中断
                        pressingState = false
                    }
                },
                perform: {
                    pressingState = false
                    resetExecution = true
                })
            // 長押しによるボタンゲージの増加処理
            .onReceive(pressingTimer) { _ in
                if pressingState {
                    // Timerの更新頻度が0.01のため、100で割る
                    pressingFrame += (cancelButtonFrame / 100)
                } else {
                    pressingFrame = 0
                }
            }
            // idが更新されるたびに、タスクがキャンセル -> 再実行される
            .task(id: resetExecution) {
                guard let resetExecution else { return }

                do {
                    try await vm.resetController(to: teamVM.team, element: element)
                    self.resetExecution = nil
                } catch {
                    print(error.localizedDescription)
                    self.resetExecution = nil
                }
            }
    }
}

/// 通知機能における通知タイプを管理する列挙体。
enum LogType: Codable, Equatable {
    case addItem(Item)
    case updateItem(CompareItem)
    case deleteItem(Item)
    case commerce([CompareItem])
    case join(User)
    case updateUser(CompareUser)
    case updateTeam(CompareTeam)

    var type: LogType {
        return self
    }

    var setRule: SetType {
        switch self {
        case .addItem, .updateItem, .deleteItem, .commerce, .join, .updateTeam:
            return .global
        case .updateUser:
            return .local
        }
    }
    /// 通知の削除時に、メンバー全員の通知データをまとめて削除(global)するか、ローカルだけ削除(local)するかを管理する。
    var removeRule: RemoveType {
        switch self {
        case .addItem, .updateItem, .deleteItem, .commerce, .join, .updateTeam:
            return .global
        case .updateUser:
            return .local
        }
    }
    /// 通知に渡すメッセージテキスト。
    var message: String {
        switch self {
        case .addItem:
            return "新しいアイテムが追加されました。"
        case .updateItem:
            return "アイテム情報が更新されました。"
        case .deleteItem:
            return "アイテムが削除されました。"
        case .commerce(let items):
            return "カート内 \(items.count) 個のアイテムが精算されました。"
        case .join(let user):
            return "\(user.name) さんがチームに参加しました！"
        case .updateUser:
            return "ユーザー情報が更新されました。"
        case .updateTeam:
            return "チーム情報が更新されました。"
        }
    }

    /// 通知アイコンに用いられる画像URL。WebImageによって表示される。
    var imageURL: URL? {
        switch self {
        case .addItem(let item):
            return item.photoURL
        case .updateItem(let item):
            return item.after.photoURL
        case .deleteItem(let item):
            return item.photoURL
        case .commerce(let items):
            return items.first?.after.photoURL
        case .join(let user):
            return user.iconURL
        case .updateUser(let user):
            return user.after.iconURL
        case .updateTeam(let team):
            return team.after.iconURL
        }
    }
    var symbol: String {
        switch self {
        case .addItem, .updateItem, .deleteItem:
            return "shippingbox.fill"
        case .commerce:
            return "cart.fill"
        case .join:
            return "person.fill"
        case .updateUser:
            return "person.fill"
        case .updateTeam:
            return "cube.transparent"
        }
    }

    /// 通知に用いられるカラー。主に通知アイコンの背景色に使う。
    var color: Color {
        switch self {
        case .addItem, .updateItem, .join, .updateUser:
            return Color.gray
        case .commerce:
            return Color.mint
        case .deleteItem(_):
            return Color.red
        case .updateTeam:
            return Color.userGray1
        }
    }
    /// 通知が画面上に残る時間
    var stayTime: CGFloat {
        switch self {
        case .addItem, .updateItem, .updateUser, .updateTeam, .commerce:
            return 3.0
        case .join, .deleteItem:
            return 5.0
        }
    }
}
