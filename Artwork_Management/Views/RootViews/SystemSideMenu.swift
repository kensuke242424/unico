//
//  SystemSideMenuView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/10.
//

import SwiftUI

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
    var showdeletedAllTeamProgress: Bool = false
    
    // 操作チームを変更するハーフモーダルを管理
    var showChangeTeamSheet: Bool = false
    var teamsListSheetEdit: Bool = false

    // ユーザー登録シートモーダルの管理プロパティ
    var showUserEntrySheet: Bool = false

    // ユーザーが移動先に選択したチームが格納される
    var selectedTeam: JoinTeam?
}

struct SystemSideMenu: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @StateObject var itemVM: ItemViewModel
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var progressVM: ProgressViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

    @EnvironmentObject var logInVM : LogInViewModel
    @EnvironmentObject var teamVM  : TeamViewModel
    @EnvironmentObject var userVM  : UserViewModel
    @EnvironmentObject var tagVM   : TagViewModel

    @Binding var inputTab: InputTab
    @State private var inputSideMenu: InputSideMenu = InputSideMenu()

    @GestureState var dragOffset: CGFloat = 0.0
    let menuRowHeight: CGFloat = 60

    var body: some View {

        ZStack {
            // Blur View...
            BlurView(style: .systemUltraThinMaterialDark)
            userVM.memberColor.color2
                .opacity(0.7)
                .blur(radius: 15)
                .overlay(alignment: .topLeading) {
                    Button {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            inputTab.showSideMenu = false
                        }
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .font(.title).foregroundColor(.white.opacity(0.4))
                            .padding(.leading)
                            .padding(.top, getSafeArea().top)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    JoinTeamsSideMenuIcon(teams: userVM.user!.joins)
                        .padding(.trailing, 90)
                        .padding(.top, getSafeArea().top + 10)
                }
                .alert("", isPresented: $inputSideMenu.isShowChangeTeamAlert) {
                    Button("キャンセル") {}
                    Button("移動する") {
                        // フェッチするチームデータを管理するUserModel内のlastLogInの値を更新後に、再fetchを実行
                        Task {
                            inputSideMenu.showChangeTeamSheet = false
                            await userVM.updateLastLogInTeam(selected: inputSideMenu.selectedTeam)
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
                    Text("\(inputSideMenu.selectedTeam?.name ?? "No Name")に移動しますか？")
                } // team change Alert

            VStack {

                VStack(alignment: .leading, spacing: 20) {
                    
                    SDWebImageCircleIcon(imageURL: teamVM.team?.iconURL,
                                         width   : getRect().width / 3 + 20,
                                         height  : getRect().width / 3 + 20)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) { inputTab.showUpdateTeam.toggle() }
                    }
                    .overlay(alignment: .bottom) {
                        if teamVM.team!.name.count < 12 {
                            Text(teamVM.team!.name)
                                .font(.title3.bold()).foregroundColor(.white)
                                .frame(width: getRect().width * 0.7)
                                .offset(y: 35)
                        }
                    }
                    if teamVM.team!.name.count >= 12 {
                        Text(teamVM.team!.name)
                            .font(.title3.bold()).foregroundColor(.white)
                            .frame(width: getRect().width * 0.7)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.vertical)
                
                Spacer(minLength: 40)
                
                HStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 60) {
                            
                            // Item Menu...
                            VStack(alignment: .leading) {
                                
                                SideMenuButton(open: $inputSideMenu.item, title: "アイテム", image: "shippingbox")
                                
                                if inputSideMenu.item {
                                    
                                    VStack(alignment: .leading, spacing: 40) {
                                        Label("アイテム追加", systemImage: "shippingbox.fill")
                                            .onTapGesture { navigationVM.path.append(EditItemPath.create) }
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 210, height: menuRowHeight, alignment: .topLeading)
                                    .offset(x: 20, y: 30)
                                }
                            }
                            
                            // Tag Menu...
                            VStack(alignment: .leading) {
                                
                                HStack {
                                    
                                    SideMenuButton(open: $inputSideMenu.tag, title: "タグ", image: "tag")
                                    
                                    if inputSideMenu.tag {
                                        
                                        if tagVM.tags.count > 2 {
                                            Button {
                                                withAnimation {
                                                    inputSideMenu.editMode = inputSideMenu.editMode.isEditing ? .inactive : .active
                                                }
                                            } label: {
                                                Image(systemName: inputSideMenu.editMode.isEditing ? "gearshape.fill" : "gearshape")
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
                                .onChange(of: inputSideMenu.tag) { newValue in
                                    if !newValue {
                                        inputSideMenu.editMode = .inactive
                                    }
                                }
                                
                                if inputSideMenu.tag {
                                    
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
                                                        
                                                        if inputSideMenu.editMode == .inactive {
                                                            Image(systemName: "highlighter")
                                                                .foregroundColor(.orange)
                                                                .opacity(inputSideMenu.editMode.isEditing ? 0.0 : 0.6)
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
                                                                .opacity(inputSideMenu.editMode.isEditing ? 0.6 : 0.0)
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
                                        .environment(\.editMode, $inputSideMenu.editMode)
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

                                SideMenuButton(open: $inputSideMenu.team, title: "チーム", image: "cube.transparent")

                                if inputSideMenu.team {

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

                                        Label("チームを追加", systemImage: "person.2.crop.square.stack.fill")
                                            .onTapGesture { inputSideMenu.isShowCreateTeamAlert.toggle() }
                                            .alert("", isPresented: $inputSideMenu.isShowCreateTeamAlert) {
                                                Button("戻る") {}
                                                Button("はい") {
                                                    withAnimation(.spring(response: 0.5)) {
                                                        inputTab.showSideMenu = false
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                        withAnimation(.spring(response: 0.7)) {
                                                            logInVM.rootNavigation = .join
                                                        }
                                                    }
                                                }
                                            } message: {
                                                Text("新規チームの追加画面に移動します。")
                                            } // alert
                                        
                                        Label("チームを変更", systemImage: "repeat")
                                            .onTapGesture { inputSideMenu.showChangeTeamSheet.toggle() }

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

                                SideMenuButton(open: $inputSideMenu.account, title: "アカウント", image: "person")

                                if inputSideMenu.account {

                                    VStack(alignment: .leading, spacing: 40) {

                                        Label("ユーザー情報変更", systemImage: "person.fill")
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.5)) { inputTab.showUpdateUser.toggle() }
                                            }

                                        Label("アカウント登録", systemImage: "person.crop.square.filled.and.at.rectangle.fill")
                                            .onTapGesture {
                                                inputSideMenu.showUserEntrySheet.toggle()
                                            }
                                            .offset(x: -3)


                                        Label("ログアウト", systemImage: "door.right.hand.open")
                                            .foregroundColor(.orange)
                                            .onTapGesture { inputSideMenu.isShowLogOutAlert.toggle() }

                                    } // VStack
                                    .foregroundColor(.white)
                                    // メニュー一つ分のheight = コンテンツ数 * 60
                                    .frame(width: 210, height: menuRowHeight * 3, alignment: .topLeading)
                                    .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                                    .offset(x: 20, y: 30)
                                    .alert("確認", isPresented: $inputSideMenu.isShowLogOutAlert) {
                                        Button("戻る") { inputSideMenu.isShowLogOutAlert.toggle() }
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

                                SideMenuButton(open: $inputSideMenu.help, title: "システム", image: "gearshape")

                                if inputSideMenu.help {

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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .top])

                    } // ScrollView
                    .frame(width: UIScreen.main.bounds.width / 2 + 100)
                    Spacer()
                }
            } // VStack
            .offset(y: UIScreen.main.bounds.height / 12)

        } // ZStack
        .sheet(isPresented: $inputSideMenu.showChangeTeamSheet) {
            ChangeTeamSheetView(teams: userVM.user?.joins ?? [])
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $inputSideMenu.showUserEntrySheet) {
            UserEntryRecommendationView(isShow: $inputSideMenu.showUserEntrySheet)
        }
        // NOTE: ローカルのタグ順番操作をfirestoreに保存
        .onChange(of: inputSideMenu.editMode) { newEdit in
            if newEdit == .inactive {
                tagVM.updateOderTagIndex(teamID: teamVM.team!.id)
            }
        }
        .onChange(of: inputTab.showSideMenu) { newValue in
            if !newValue {
                inputSideMenu.item     = false
                inputSideMenu.tag      = false
                inputSideMenu.team     = false
                inputSideMenu.account  = false
                inputSideMenu.help     = false
                inputSideMenu.editMode = .inactive
            }
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
        // TODO: トランジションの確認
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
    func ChangeTeamSheetView(teams: [JoinTeam]) -> some View {
        NavigationStack {
            Group {
                if teams.count == 1 {
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
                        ForEach(teams.filter({ $0.teamID != teamVM.team!.id}), id: \.self) { teamRow in
                            HStack(spacing: 20) {
                                if inputSideMenu.teamsListSheetEdit {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .transition(.opacity.combined(with: .offset(x: -30)))
                                        .onTapGesture {
                                            inputSideMenu.selectedTeam = teamRow
                                            inputSideMenu.showdeleteTeamAlert.toggle()
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
                                inputSideMenu.selectedTeam = teamRow
                                inputSideMenu.isShowChangeTeamAlert.toggle()
                            }
                        } // ForEath
                    } // List
                    .offset(y: -30)
                    .alert("確認", isPresented: $inputSideMenu.showdeleteTeamAlert) {
                        Button("削除する", role: .destructive) {

                            Task {
                                guard let selectedTeam = inputSideMenu.selectedTeam else { return }
                                inputSideMenu.showdeletedAllTeamProgress = true
                                try await userVM.deleteMembersJoinTeam(selected: selectedTeam,
                                                                       members : teamVM.team!.members)

                                await teamVM.deleteAllTeamImages()
                                await itemVM.deleteAllItemImages()
                                await teamVM.deleteSelectedTeamDocuments(selected: selectedTeam)
                                inputSideMenu.showdeletedAllTeamProgress = false
                                //TODO: 削除完了アラートが表示されないぞ？？？
                                inputSideMenu.showdeletedAllTeamAlert = true

                            }
                        }
                    } message: {
                        Text("チーム内のアイテム、タグ、メンバー情報を含めた全てのデータを消去します。チーム削除を実行しますか？")
                    } // alert
                    .alert("", isPresented: $inputSideMenu.showdeletedAllTeamAlert) {
                        Button("OK") {
                            // TODO: 他のチームデータをfetch
                            // 他のチームが存在しなければ、チーム作成画面へ遷移
                        }
                    } message: {
                        Text("チームデータの消去が完了しました")
                    } // team delete Alert
                    .alert("", isPresented: $inputSideMenu.isShowChangeTeamAlert) {
                        Button("キャンセル") {}
                        Button("移動する") {
                            // フェッチするチームデータを管理するUserModel内のlastLogInの値を更新後に、再fetchを実行
                            Task {
                                inputSideMenu.showChangeTeamSheet = false
                                await userVM.updateLastLogInTeam(selected: inputSideMenu.selectedTeam)
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
                        Text("\(inputSideMenu.selectedTeam?.name ?? "No Name")に移動しますか？")
                    } // team change Alert
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(inputSideMenu.teamsListSheetEdit ? "終了" : "編集") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            inputSideMenu.teamsListSheetEdit.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        inputSideMenu.isShowCreateTeamAlert.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .alert("", isPresented: $inputSideMenu.isShowCreateTeamAlert) {
                        Button("戻る") {}
                        Button("はい") {
                            inputSideMenu.showChangeTeamSheet.toggle()
                            withAnimation(.spring(response: 0.5)) {
                                logInVM.rootNavigation = .join
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
    func JoinTeamsSideMenuIcon(teams: [JoinTeam]) -> some View {
        
        HStack(spacing: 12) {
            ForEach(Array(teams.enumerated()), id: \.offset) { offset, team  in
                if !teams.isEmpty &&
                    offset <= 2   &&
                    team.teamID != userVM.user!.lastLogIn {
                    SDWebImageCircleIcon(imageURL: team.iconURL,
                                         width: 28, height: 28)
                    .onTapGesture {
                        inputSideMenu.selectedTeam = team
                        inputSideMenu.isShowChangeTeamAlert.toggle()
                    }
                }
            }
            
            Button {
             //TODO: チーム選択ハーフモーダル
                inputSideMenu.showChangeTeamSheet.toggle()
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
