//
//  SystemSideMenuView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/10.
//

import SwiftUI

struct SystemSideMenu: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @StateObject var itemVM: ItemViewModel
    @StateObject var homeVM: HomeViewModel
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var progressVM: ProgressViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

    @EnvironmentObject var logInVM : AuthViewModel
    @EnvironmentObject var teamVM  : TeamViewModel
    @EnvironmentObject var userVM  : UserViewModel
    @EnvironmentObject var tagVM   : TagViewModel

    @Binding var inputTab: InputTab
    @State private var input: InputSideMenu = InputSideMenu()

    @State private var teamEscaping: Bool?

    @GestureState var dragOffset: CGFloat = 0.0
    let menuRowHeight: CGFloat = 60

    var body: some View {

        VStack(alignment: .leading) {

            /// サイドメニューを閉じるボタンと所属チームアイコン群が並んだビュー領域
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                        inputTab.showSideMenu = false
                    }
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                JoinTeamsSideMenuIcon(joins: userVM.joins)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .alert("", isPresented: $input.isShowChangeTeamAlert) {
                        Button("キャンセル") {}
                        Button("移動する") {
                            // フェッチするチームデータを管理するUserModel内のlastLogInの値を更新後に、再fetchを実行
                            Task {
                                input.showChangeTeamSheet = false
                                try await userVM.updateLastLogInTeam(teamId: input.selectedTeam?.id)
                                withAnimation(.spring(response: 0.5)) {
                                    progressVM.showCubesProgress = true
                                    inputTab.showSideMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring(response: 0.2)) {
                                        logInVM.rootNavigation = .fetch
                                    }
                                }
                            }
                        }
                    } message: {
                        Text("\(input.selectedTeam?.name ?? "No Name")に移動しますか？")
                    } // team change Alert
            }
            .frame(width: getRect().width * 0.7)
            .padding(.top, getSafeArea().top + 10)
            .padding(.bottom)

            /// チームアイコンとチーム名
            VStack(alignment: .leading, spacing: 15) {
                var iconSize: CGFloat { userDeviseSize == .small ? 140 : 160 }
                let teamName: String = teamVM.team?.name ?? "No Name"

                SDWebImageCircleIcon(imageURL: teamVM.team?.iconURL,
                                     width   : iconSize,
                                     height  : iconSize)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5)) { inputTab.showUpdateTeam.toggle() }
                }

                CustomOneLineLimitText(text: teamName, limit: 20)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: teamName.count >= 8 ? .infinity : iconSize,
                           alignment: teamName.count >= 8 ? .leading : .center)
            }

            ScrollView(showsIndicators: false) {
                /// メニュー列全体
                VStack(alignment: .leading, spacing: 60) {

                    // Tag Menu...
                    VStack(alignment: .leading) {

                        HStack {

                            SideMenuButton(open: $input.tag, title: "タグ", image: "tag")

                            if input.tag {

                                if tagVM.tags.count > 2 {
                                    Button {
                                        withAnimation {
                                            input.editMode = input.editMode.isEditing ? .inactive : .active
                                        }
                                    } label: {
                                        Image(systemName: input.editMode.isEditing ? "gearshape.fill" : "gearshape")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16)
                                            .foregroundColor(.gray)
                                            .padding(4)
                                            .background {
                                                Circle()
                                                    .fill(.white.gradient)
                                                    .shadow(radius: 3, x: 1, y: 1)
                                            }
                                    }
                                    .offset(x: 20)
                                }

                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        inputTab.selectedTag = nil
                                        tagVM.showEdit = true
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10)
                                        .foregroundColor(.gray)
                                        .padding(6)
                                        .background {
                                            Circle()
                                                .fill(.white.gradient)
                                                .shadow(radius: 3, x: 1, y: 1)
                                        }
                                }
                                .offset(x: 27)
                            }
                        } // HStack
                        .onChange(of: input.tag) { newValue in
                            if !newValue {
                                input.editMode = .inactive
                            }
                        }

                        if input.tag {

                            Spacer(minLength: 0)

                            if tagVM.tags.count > 2 {
                                List {

                                    ForEach(Array(tagVM.tags.enumerated()), id: \.offset) { offset, tag in

                                        if tag != tagVM.tags.first! && tag != tagVM.tags.last! {
                                            HStack {
                                                Image(systemName: "tag.fill")
                                                    .font(.caption)
                                                    .foregroundColor(
                                                        userVM.user?.userColor.colorAccent ?? .gray
                                                    )
                                                    .opacity(0.6)

                                                Text(tag.tagName)
                                                    .lineLimit(1)
                                                    .frame(alignment: .leading)
                                                    .foregroundColor(.white)

                                                Spacer()

                                                if input.editMode == .inactive {
                                                    Image(systemName: "highlighter")
                                                        .foregroundColor(.orange)
                                                        .opacity(input.editMode.isEditing ? 0.0 : 0.6)
                                                        .onTapGesture {
                                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                                inputTab.selectedTag = tag
                                                                tagVM.showEdit = true
                                                            }
                                                        }
                                                }
                                            } // HStack
                                            .overlay {
                                                if colorScheme == .light {
                                                    Image(systemName: "line.3.horizontal")
                                                        .foregroundColor(.gray)
                                                        .opacity(input.editMode.isEditing ? 0.6 : 0.0)
                                                        .frame(width: UIScreen.main.bounds.width * 0.58, alignment: .leading)
                                                        .offset(x: UIScreen.main.bounds.width * 0.44)
                                                }
                                            }
                                            .listRowBackground(Color.clear)
                                        }
                                    }
                                    .onDelete(perform: rowRemove)
                                    .onMove(perform: rowReplace)
                                } // List
                                .environment(\.editMode, $input.editMode)
                                .frame(width: UIScreen.main.bounds.width / 2 + 60,
                                       height: menuRowHeight + (40 * CGFloat(tagVM.tags.count - 2)))
                                .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                                .scrollContentBackground(.hidden)
                                .offset(x: -10)
                            } else {

                                Text("登録タグはありません")
                                    .font(.subheadline).foregroundColor(.white)
                                    .opacity(0.7)
                                    .frame(height: menuRowHeight)
                                    .offset(y: 30)

                            } // if tagVM.tags.count > 2
                        } // if inputSideMenu.tag...
                    }

                    // Team menu...
                    VStack(alignment: .leading) {

                        SideMenuButton(open: $input.team, title: "チーム", image: "cube.transparent")

                        if input.team {

                            VStack(alignment: .leading, spacing: 40) {

                                Label("チーム情報変更", systemImage: "cube.transparent.fill")
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5)) { inputTab.showUpdateTeam.toggle() }
                                    }

                                Label("メンバー招待", systemImage: "person.wave.2.fill")
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                            teamVM.isShowSearchedNewMemberJoinTeam.toggle()
                                        }
                                    }
                                    // 匿名ユーザー時の制限表現ビュー
                                    .overlay {
                                        if userVM.isAnonymous {
                                            RoundedRectangle(cornerRadius: 20)
                                                .scaleEffect(1.3)
                                                .foregroundColor(.black)
                                                .opacity(0.5)
                                                .overlay(alignment: .topTrailing) {
                                                    Image(systemName: "lock.fill")
                                                        .foregroundColor(.yellow)
                                                        .offset(x: 25, y: -10)
                                                }
                                                .onTapGesture {
                                                    inputTab.showEntryAccount.toggle()
                                                }
                                        }
                                    }

                                Label("チームを追加", systemImage: "person.2.crop.square.stack.fill")
                                    .onTapGesture { input.isShowCreateTeamAlert.toggle() }
                                    .alert("", isPresented: $input.isShowCreateTeamAlert) {
                                        Button("戻る") {}
                                        Button("はい") {
                                            withAnimation(.spring(response: 0.5)) {
                                                inputTab.showSideMenu = false
                                                input.showChangeTeamSheet = false
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation(.spring(response: 0.7)) {
                                                    logInVM.rootNavigation = .join
                                                }
                                            }
                                        }
                                    } message: {
                                        Text("新規チームの追加画面に移動します。")
                                    } // alert

                                Label("チームを変更", systemImage: "repeat")
                                    .onTapGesture { input.showChangeTeamSheet.toggle() }

                                Label("背景の変更", systemImage: "photo.artframe")
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                                            inputTab.showSideMenu = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation(.spring(response: 0.7, blendDuration: 1)) {
                                                backgroundVM.showEdit.toggle()
                                            }
                                        }
                                    }

                            } // VStack
                            .foregroundColor(.white)
                            // メニュー一つ分のheight = コンテンツ数 * 60
                            .frame(width: 210, height: menuRowHeight * 5, alignment: .topLeading)
                            .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                            .offset(x: 20, y: 30)
                        }
                    }

                    // Account Menu...
                    VStack(alignment: .leading) {

                        SideMenuButton(open: $input.account, title: "アカウント", image: "person")

                        if input.account {

                            VStack(alignment: .leading, spacing: 40) {

                                Label("ユーザー情報変更", systemImage: "person.fill")
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5)) { inputTab.showUpdateUser.toggle() }
                                    }

                                Label("アカウント登録", systemImage: "person.crop.square.filled.and.at.rectangle.fill")
                                    .onTapGesture {
                                        input.showUserEntrySheet.toggle()
                                    }
                                    .offset(x: -3)


                                Label("ログアウト", systemImage: "door.right.hand.open")
                                    .foregroundColor(.orange)
                                    .onTapGesture { input.isShowLogOutAlert.toggle() }

                            } // VStack
                            .foregroundColor(.white)
                            // メニュー一つ分のheight = コンテンツ数 * 60
                            .frame(width: 210, height: menuRowHeight * 3, alignment: .topLeading)
                            .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                            .offset(x: 20, y: 30)
                            .alert("確認", isPresented: $input.isShowLogOutAlert) {
                                Button("戻る") { input.isShowLogOutAlert.toggle() }
                                Button("ログアウト") {
                                    progressVM.showLoading.toggle()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        progressVM.showLoading.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeIn(duration: 0.5)) {
                                                logInVM.rootNavigation = .logIn
                                                logInVM.logOut()
                                            }
                                        }
                                    }
                                }
                            } message: {
                                if userVM.isAnonymous {
                                    Text("お試し中にログアウトすると、元のデータに再度ログインすることはできません。ログアウトしますか？")
                                } else {
                                    Text("アカウントからログアウトして、ログイン画面に戻ります。よろしいですか？")
                                }
                            } // alert
                        }
                    }

                    // Help Menu...
                    VStack(alignment: .leading) {

                        SideMenuButton(open: $input.help, title: "システム", image: "gearshape")

                        if input.help {

                            VStack(alignment: .leading, spacing: 40) {

                                Label("アプリ設定", systemImage: "paintbrush.pointed.fill")
                                    .onTapGesture { navigationVM.path.append(ApplicationSettingPath.root)
                                    }

                                Label("ホーム編集", systemImage: "house.fill")
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                                            inputTab.showSideMenu = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation(.spring(response: 0.7, blendDuration: 1)) {
                                                homeVM.isActiveEdit.toggle()
                                            }
                                        }
                                    }

                                Label("システム設定", systemImage: "gearshape.fill")
                                    .onTapGesture { navigationVM.path.append(SystemPath.root)
                                    }

                            } // VStack
                            .foregroundColor(.white)
                            // メニュー一つ分のheight = コンテンツ数 * 60
                            .frame(width: 210, height: menuRowHeight * 3, alignment: .topLeading)
                            .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                            .offset(x: 20, y: 30)

                        }
                    }
                    /// スクロール下に余白を作るため
                    Color.clear
                        .frame(height: 150)
                } // VStack(メニュー列全体)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

            } // ScrollView
            .frame(maxWidth: .infinity)
            .padding(.top)

        } // VStack
        .padding(.leading)
        .background {
            // Blur View...
            BlurView(style: .systemUltraThinMaterialDark)
            userVM.memberColor.color2
                .opacity(0.7)
                .blur(radius: 15)
        }
        .clipShape(SideMenuShape())
        .contentShape(SideMenuShape())
        .background(

            SideMenuShape()
                .stroke(
                    .linearGradient(.init(colors: [
                        Color.customLightGray1,
                        Color.customLightGray1.opacity(0.7),
                        Color.customLightGray1.opacity(0.5),
                        Color.clear
                    ]), startPoint: .top, endPoint: .bottom),
                    lineWidth: 7)
                .padding(.leading, -50)

        )
        .sheet(isPresented: $input.showChangeTeamSheet) {
            ChangeTeamSheetView(current: teamVM.team, joins: userVM.joins)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $input.showUserEntrySheet) {
            UserEntryRecommendationView(isShow: $input.showUserEntrySheet)
        }
        // NOTE: ローカルのタグ順番操作をfirestoreに保存
        .onChange(of: input.editMode) { newEdit in
            if newEdit == .inactive {
                tagVM.updateOderTagIndex(teamID: teamVM.team!.id)
            }
        }
        .onChange(of: inputTab.showSideMenu) { newValue in
            if !newValue {
                input.item     = false
                input.tag      = false
                input.team     = false
                input.account  = false
                input.help     = false
                input.editMode = .inactive
            }
        }
        .task(id: teamEscaping) {
            guard let _ = teamEscaping else {return }
            guard let selectedTeam = input.selectedTeam else {
                print("チーム脱退処理失敗")
                teamEscaping = nil
                return
            }

            // ⚠️ ------  チーム脱退処理実行  -----  ⚠️
            Task {
                input.showEscapeTeamProgress = true
                // 対象チーム内のメンバーデータ（members）から自身のメンバーデータを消去
                await teamVM.deleteTeamMemberDocument(teamId: selectedTeam.id, memberId: userVM.uid)
                /// 自身の所属チームサブコレクション（joins）から対象チームデータを消去
                try await userVM.deleteJoinTeamFromMyData(for: selectedTeam)

                /// チーム内のメンバーズドキュメントIdを取得し、他メンバーがいない場合は、チームデータごと削除する
                let membersId = await teamVM.getMembersId(teamId: selectedTeam.id)

                if let membersId, membersId.isEmpty {
                    print("\(selectedTeam.name)のチームデータ削除実行")
                    // チームが持っている各データ削除
                    await teamVM.deleteItemDocuments(teamId: selectedTeam.id)
                    await teamVM.deleteTagDocuments(teamId: selectedTeam.id)
                    await teamVM.deleteTeamDocument(for: selectedTeam.id)
                }

                input.showEscapeTeamProgress = false
                input.selectedTeam = nil
                teamEscaping = nil
            }
        }

        .ignoresSafeArea()
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .updating(self.$dragOffset, body: { (value, state, _) in
                    if value.translation.width < 0 {
                        state = value.translation.width
                    }})
                .onEnded { value in
                    if value.translation.width < -100 {
                        withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                            inputTab.showSideMenu = false
                        }
                    }
                }
        )
        .animation(.interpolatingSpring(mass           : 0.8,
                                        stiffness      : 100,
                                        damping        : 80,
                                        initialVelocity: 0.1),
                                        value          : dragOffset
        )
    } // body
    
    @ViewBuilder
    func ChangeTeamSheetView(current: Team?, joins: [JoinTeam]) -> some View {
        NavigationStack {
            Group {
                if joins.count == 1 {
                    VStack(spacing: 20) {
                        Image(systemName: "cube.transparent")
                            .resizable()
                            .scaledToFit()
                            .font(.subheadline)
                            .frame(width: 100)
                        
                        Text("他の所属チームはありません")
                            .tracking(2)
                    }
                    .opacity(0.5)
                    
                } else {
                    List {
                        if let current {
                            ForEach(joins.filter({ $0.id != current.id}), id: \.self) { teamRow in
                                HStack(spacing: 20) {
                                    if input.teamsListSheetEdit {
                                        Image(systemName: "door.left.hand.open")
                                            .foregroundColor(.orange)
                                            .transition(.opacity.combined(with: .offset(x: -30)))
                                            .onTapGesture {
                                                input.selectedTeam = teamRow
                                                input.showdeleteTeamAlert.toggle()
                                            }
                                    }
                                    SDWebImageCircleIcon(imageURL: teamRow.iconURL,
                                                         width: 50, height: 50)
                                    Text(teamRow.name)
                                        .lineLimit(1)
                                }
                                .frame(height: 60)
                                .listRowBackground(Color.clear)
                                .onTapGesture {
                                    input.selectedTeam = teamRow
                                    input.isShowChangeTeamAlert.toggle()
                                }
                            } // ForEath
                        }
                    } // List
                    .offset(y: -30)

                    // チームの脱退
                    .alert("確認", isPresented: $input.showdeleteTeamAlert) {
                        Button("脱退する", role: .destructive) {
                            // ⚠️ ----  チーム脱退処理の実行 ------- ⚠️
                            teamEscaping = true
                        }
                    } message: {
                        Text("\(input.selectedTeam?.name ?? "No Name")から脱退しますか？（他に所属メンバーがいない場合、チームデータはすべて削除されます）")
                    } // alert

                    .alert("", isPresented: $input.showdeletedAllTeamAlert) {
                        Button("OK") {
                            // TODO: 他のチームデータをfetch
                            // 他のチームが存在しなければ、チーム作成画面へ遷移
                        }
                    } message: {
                        Text("チームデータの消去が完了しました")
                    } // team delete Alert

                    // チーム移動
                    .alert("", isPresented: $input.isShowChangeTeamAlert) {
                        Button("キャンセル") {}
                        Button("移動する") {
                            // フェッチするチームデータを管理するUserModel内のlastLogInの値を更新後に、再fetchを実行
                            Task {
                                input.showChangeTeamSheet = false
                                try await userVM.updateLastLogInTeam(teamId: input.selectedTeam?.id)
                                withAnimation(.spring(response: 0.5)) {
                                    progressVM.showCubesProgress = true
                                    inputTab.showSideMenu = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring(response: 0.2)) {
                                        logInVM.rootNavigation = .fetch
                                    }
                                }
                            }
                        }
                    } message: {
                        Text("\(input.selectedTeam?.name ?? "No Name")に移動しますか？")
                    } // team change Alert
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(input.teamsListSheetEdit ? "終了" : "編集") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            input.teamsListSheetEdit.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        input.isShowCreateTeamAlert.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    /// MEMO: 同様のalertをsidemenu側にも実装しているが、
                    /// シートビュー表示時、↑は反応しないため、こちらにも置いている
                    .alert("", isPresented: $input.isShowCreateTeamAlert) {
                        Button("戻る") {}
                        Button("はい") {
                            withAnimation(.spring(response: 0.5)) {
                                inputTab.showSideMenu = false
                                input.showChangeTeamSheet = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.7)) {
                                    logInVM.rootNavigation = .join
                                }
                            }
                        }
                    } message: {
                        Text("新規チームの追加画面に移動します。")
                    } // alert
                }
            }
            .navigationTitle("チーム変更")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    func JoinTeamsSideMenuIcon(joins: [JoinTeam]) -> some View {
        
        HStack(spacing: 12) {
            ForEach(Array(joins.enumerated()), id: \.offset) { offset, team  in
                if !joins.isEmpty &&
                    offset <= 2   &&
                    team.id != userVM.user!.lastLogIn {
                    SDWebImageCircleIcon(imageURL: team.iconURL,
                                         width: 28, height: 28)
                    .onTapGesture {
                        input.selectedTeam = team
                        input.isShowChangeTeamAlert.toggle()
                    }
                }
            }
            
            Button {
             //TODO: チーム選択ハーフモーダル
                input.showChangeTeamSheet.toggle()
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.white)
                    .font(.title2)
            }
        }
        .frame(alignment: .trailing)
    }

    func rowRemove(offsets: IndexSet) {
        for tagIndex in offsets {
            print(tagIndex)
            tagVM.deleteTag(deleteTag: tagVM.tags[tagIndex], teamID: teamVM.team!.id)
        }
    }

    func rowReplace(_ from: IndexSet, _ to: Int) {
        withAnimation(.spring()) {
            tagVM.tags.move(fromOffsets: from, toOffset: to)
        }
    }
    /// チーム移動時に、現在のチームデータのリスナーをリセットするメソッド。
    func removeListeners() {
        userVM.removeListener()
        teamVM.removeListener()
        tagVM.removeListener()
        itemVM.removeListener()
    }
}

struct SideMenuButton: View {

    @Binding var open: Bool
    let title: String
    let image: String

    var body: some View {
        Button {
            withAnimation { open.toggle() }
        } label: {
            HStack(spacing: 12) {

                Image(systemName: image)
                    .resizable()
                    .foregroundColor(.white)
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(open ? 1.1 : 1.0)
                    .frame(width: 20, height: 20)

                Text(title)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))

                Image(systemName: "chevron.down")
                    .foregroundColor(open ? .blue : .white).opacity(open ? 1.0 : 0.2)
                    .rotationEffect(Angle(degrees: open ? -180 : 0))
            }
            .offset(x: open ? 7 : 0)
        }
    }
}

struct SideMenuShape: Shape {
    func path(in rect: CGRect) -> Path {

        return Path { path in
            let width = rect.width - 100
            let height = rect.height

            path.move(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))

            // Curve Shape...
            path.move(to: CGPoint(x: width, y: 0))

            path.addCurve(to: CGPoint(x: width, y: height + 100),
                          control1: CGPoint(x: width + 100, y: height / 3),
                          control2: CGPoint(x: width - 100, y: height / 2))

        }
    }
}

struct InputSideMenu {
    // メニュー各項目の状態を管理
    var account: Bool = false
    var team: Bool = false
    var item: Bool = false
    var tag: Bool = false
    var help: Bool = false

    // タグリストの状態を管理
    var editMode: EditMode = .inactive
    var selectTag: Tag = Tag(oderIndex: 1, tagName: "", tagColor: .red)

    // サイドメニュー内でのアラートを管理
    var isShowLogOutAlert    : Bool = false
    var isShowCreateTeamAlert: Bool = false
    var isShowChangeTeamAlert: Bool = false
    var showdeleteTeamAlert  : Bool = false

    // チームデータ消去時の状態を管理するプロパティ
    var showdeletedAllTeamAlert   : Bool = false
    var showEscapeTeamProgress: Bool = false

    // 操作チームを変更するハーフモーダルを管理
    var showChangeTeamSheet: Bool = false
    var teamsListSheetEdit: Bool = false

    // ユーザー登録シートモーダルの管理プロパティ
    var showUserEntrySheet: Bool = false

    // ユーザーが移動先に選択したチームが格納される
    var selectedTeam: JoinTeam?
}
