//
//  SystemSideMenuView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/10.
//

import SwiftUI

struct InputSideMenu {
    var account: Bool = false
    var team: Bool = false
    var item: Bool = false
    var tag: Bool = false
    var help: Bool = false
    var editMode: EditMode = .inactive
    var selectTag: Tag = Tag(oderIndex: 1, tagName: "", tagColor: .red)
    var isShowLogOutAlert: Bool = false
}

struct SystemSideMenu: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel
    @StateObject var logInVM: LogInViewModel

    @Binding var inputHome: InputHome
    @Binding var inputImage: InputImage
    @Binding var inputTag: InputTagSideMenu
    @Binding var inputSideMenu: InputSideMenu

    @GestureState var dragOffset: CGFloat = 0.0

    var body: some View {

        ZStack {
            // Blur View...
            BlurView(style: .systemUltraThinMaterialDark)

            userVM.users.first!.userColor.color1
                .opacity(0.7)
                .blur(radius: 15)
                .overlay(alignment: .topLeading) {
                    Button {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            inputHome.isShowSystemSideMenu.toggle()
                        }
                        withAnimation(.easeIn(duration: 0.2)) {
                            inputHome.sideMenuBackGround.toggle()
                        }
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .font(.title).foregroundColor(.white.opacity(0.4))
                            .padding(.leading)
                            .padding(.top, getSafeArea().top)
                    }
                }

            Image(systemName: "chevron.left.2")
                .font(.title).opacity(0.5)
                .foregroundColor(.white.opacity(0.6))
                .offset(x: UIScreen.main.bounds.width / 4,
                        y: -UIScreen.main.bounds.height / 3)

            VStack {

                VStack(alignment: .leading, spacing: 20) {

                    AsyncImageCircleIcon(photoURL: teamVM.team[0].iconURL, size: getRect().width / 3 + 20)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                // チーム一覧のハーフモーダル
                            } label: {
                                Circle()
                                    .foregroundColor(userVM.users.first!.userColor.color3)
                                    .frame(width: 40, height: 40)
                                    .shadow(radius: 5, x: 5, y: 5)
                                    .overlay {
                                        Image(systemName: "person.2.crop.square.stack")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.white)
                                    }
                            }
                            .offset(x: 40, y: -10)
                        }

                        .overlay(alignment: .bottomTrailing) {
                            AsyncImageCircleIcon(photoURL: userVM.users[0].iconURL, size: getRect().width / 6)
                                .offset(x: getRect().width / 4 - 10)
                        }
                        .overlay(alignment: .bottom) {
                            if teamVM.team.first!.name.count < 12 {
                                Text(teamVM.team.first!.name)
                                    .font(.title3.bold()).foregroundColor(.white)
                                    .frame(width: getRect().width * 0.7)
                                    .offset(y: 35)
                            }
                        }
                    if teamVM.team.first!.name.count >= 12 {
                        Text(teamVM.team.first!.name)
                            .font(.title3.bold()).foregroundColor(.white)
                            .frame(width: getRect().width * 0.7)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top)

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
                                        .onTapGesture {
                                            inputHome.editItemStatus = .create
                                            inputHome.isPresentedEditItem.toggle()
                                        }

                                    } // VStack
                                    .foregroundColor(.white)
                                    .frame(width: 210, height: 60, alignment: .topLeading)
                                    .offset(x: 20, y: 30)

                                }
                            }

                            // Tag Menu...
                            VStack(alignment: .leading) {

                                HStack {

                                    SideMenuButton(open: $inputSideMenu.tag, title: "タグ", image: "tag")

                                    if inputSideMenu.tag {

                                        if tagVM.tags.count > 2 {
                                            Button(action: {
                                                withAnimation {
                                                    inputSideMenu.editMode = inputSideMenu.editMode.isEditing ? .inactive : .active
                                                }

                                            }, label: {
                                                Text(inputSideMenu.editMode.isEditing ? "終了" : "編集")
                                            })
                                            .offset(x: 20)
                                        }

                                        Button {
                                            print("タグ追加ボタンタップ")
                                            inputTag.tagSideMenuStatus = .create

                                            withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                                inputHome.isOpenEditTagSideMenu.toggle()
                                            }

                                            withAnimation(.easeIn(duration: 0.2)) {
                                                inputHome.editTagSideMenuBackground.toggle()
                                            }

                                        } label: {
                                            Image(systemName: "plus.square")
                                        }
                                        .offset(x: 30)
                                    }
                                } // HStack

                                if inputSideMenu.tag {

                                    Spacer(minLength: 0)

                                    if tagVM.tags.count > 2 {
                                        List {

                                            ForEach(Array(tagVM.tags.enumerated()), id: \.offset) { offset, tag in

                                                if tag != tagVM.tags.first! && tag != tagVM.tags.last! {
                                                    HStack {
                                                        Image(systemName: "tag.fill")
                                                            .font(.caption)
                                                            .foregroundColor(tag.tagColor.color)
                                                            .opacity(0.6)

                                                        Text(tag.tagName)
                                                            .lineLimit(1)
                                                            .frame(alignment: .leading)
                                                            .foregroundColor(.white)

                                                        Spacer()

                                                        if inputSideMenu.editMode == .inactive {
                                                            Image(systemName: "highlighter")
                                                            .foregroundColor(.gray)
                                                            .opacity(inputSideMenu.editMode.isEditing ? 0.0 : 0.6)
                                                            .onTapGesture {

                                                                print("タグ編集ボタンタップ")
                                                                inputTag.tagSideMenuStatus = .update
                                                                inputSideMenu.selectTag = tag
                                                                inputTag.newTagNameText = tag.tagName
                                                                inputTag.selectionSideMenuTagColor = tag.tagColor

                                                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                                                    inputHome.isOpenEditTagSideMenu.toggle()
                                                                }

                                                                withAnimation(.easeIn(duration: 0.2)) {
                                                                    inputHome.editTagSideMenuBackground.toggle()
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
                                        .frame(width: UIScreen.main.bounds.width * 0.58,
                                               height: 60 + (40 * CGFloat(tagVM.tags.count - 2)))
                                        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                                        .scrollContentBackground(.hidden)
                                        .offset(x: -10)
                                    } else {

                                        Text("登録タグはありません")
                                            .font(.subheadline).foregroundColor(.white)
                                            .opacity(0.7)
                                            .frame(height: 60)
                                            .offset(y: 30)

                                    } // if tagVM.tags.count > 2
                                } // if inputSideMenu.tag...
                            }

                            // Account Menu...
                            VStack(alignment: .leading) {

                                SideMenuButton(open: $inputSideMenu.account, title: "アカウント", image: "person")

                                if inputSideMenu.account {

                                    VStack(alignment: .leading, spacing: 40) {

                                        Label("ユーザ情報変更", systemImage: "person.text.rectangle")
                                        .onTapGesture {  }

                                        Label("ログアウト", systemImage: "figure.wave")
                                            .onTapGesture { inputSideMenu.isShowLogOutAlert.toggle() }

                                    } // VStack
                                    .foregroundColor(.white)
                                    // メニュー一つ分のheight = コンテンツ数 * 60
                                    .frame(width: 210, height: 120, alignment: .topLeading)
                                    .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                                    .offset(x: 20, y: 30)
                                    .alert("確認", isPresented: $inputSideMenu.isShowLogOutAlert) {
                                        Button("戻る") { inputSideMenu.isShowLogOutAlert.toggle() }
                                        Button("ログアウト") {
                                            inputHome.isShowProgress.toggle()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                inputHome.isShowProgress.toggle()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation(.easeIn(duration: 0.5)) {
                                                        logInVM.rootNavigation = .logIn
                                                        logInVM.logOut()
                                                    }
                                                }
                                            }
                                        }
                                    } message: {
                                        Text("ログイン画面に戻ります。よろしいですか？")
                                    } // alert
                                }
                            }

                            VStack(alignment: .leading) {

                                SideMenuButton(open: $inputSideMenu.team, title: "チーム", image: "person.2")

                                if inputSideMenu.team {

                                    VStack(alignment: .leading, spacing: 40) {

                                        Label("チーム情報変更", systemImage: "person.text.rectangle.fill")
                                        .onTapGesture {  }

                                        Label("メンバー招待", systemImage: "person.wave.2.fill")
                                        .onTapGesture {  }

                                        Label("新規チーム作成", systemImage: "person.2.crop.square.stack.fill")
                                        .onTapGesture {  }

                                    } // VStack
                                    .foregroundColor(.white)
                                    // メニュー一つ分のheight = コンテンツ数 * 60
                                    .frame(width: 210, height: 180, alignment: .topLeading)
                                    .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                                    .offset(x: 20, y: 30)
                                    .alert("確認", isPresented: $inputSideMenu.isShowLogOutAlert) {
                                        Button("戻る") { inputSideMenu.isShowLogOutAlert.toggle() }
                                        Button("ログアウト") {
                                            inputHome.isShowProgress.toggle()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                inputHome.isShowProgress.toggle()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation(.easeIn(duration: 0.5)) {
                                                        logInVM.rootNavigation = .logIn
                                                        logInVM.logOut()
                                                    }
                                                }
                                            }
                                        }
                                    } message: {
                                        Text("ログイン画面に戻ります。よろしいですか？")
                                    } // alert
                                }
                            }

                            // Help Menu...
                            VStack(alignment: .leading) {

                                SideMenuButton(open: $inputSideMenu.help, title: "ヘルプ", image: "questionmark.circle")

                                if inputSideMenu.help {

                                    VStack(alignment: .leading, spacing: 40) {

                                        Label("アプリについて", systemImage: "scribble.variable")
                                            .onTapGesture {  }

                                        Label("アプリの評価", systemImage: "star.bubble.fill")
                                            .onTapGesture {  }

                                        Label("利用規約", systemImage: "network.badge.shield.half.filled")
                                            .onTapGesture {  }

                                        Label("お問い合わせ", systemImage: "ellipsis.bubble.fill")
                                            .onTapGesture {  }

                                        Label("プライバシーポリシー", systemImage: "hand.raised.fill")
                                            .onTapGesture {  }

                                    } // VStack
                                    .foregroundColor(.white)
                                    // メニュー一つ分のheight = コンテンツ数 * 60
                                    .frame(width: 210, height: 120, alignment: .topLeading)
                                    .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                                    .offset(x: 20, y: 30)

                                }
                            }
                        } // VStack(メニュー列全体)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .top])

                        Color.clear
                            .frame(height: 300)

                    } // ScrollView
                    .frame(width: UIScreen.main.bounds.width / 2 + 50)
                    Spacer()
                }
            } // VStack
            .offset(y: UIScreen.main.bounds.height / 12)
        } // ZStack
        .onChange(of: inputHome.isShowSystemSideMenu) { newValue in
            if !newValue {
                inputSideMenu.item = false
                inputSideMenu.tag = false
                inputSideMenu.account = false
                inputSideMenu.help = false
                inputSideMenu.editMode = .inactive
            }
        }

        // NOTE: ローカルのタグ順番操作をfirestoreに保存
        .onChange(of: inputSideMenu.editMode) { newEdit in
            if newEdit == .inactive {
                tagVM.updateOderTagIndex(teamID: teamVM.team.first!.id)
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
                    lineWidth: 7
                )
                .padding(.leading, -50)

        )
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
                            inputHome.isShowSystemSideMenu.toggle()
                        }
                        withAnimation(.easeIn(duration: 0.2)) {
                            inputHome.sideMenuBackGround.toggle()
                        }
                    }
                }

        )
        .animation(.interpolatingSpring(mass: 0.8,
                                        stiffness: 100,
                                        damping: 80,
                                        initialVelocity: 0.1), value: dragOffset)

    } // body

    func rowRemove(offsets: IndexSet) {

        for tagIndex in offsets {
            print(tagIndex)
            tagVM.deleteTag(deleteTag: tagVM.tags[tagIndex], teamID: teamVM.team.first!.id)
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
                          control1: CGPoint(x: width + 150, y: height / 3),
                          control2: CGPoint(x: width - 150, y: height / 2))

        }
    }
}
