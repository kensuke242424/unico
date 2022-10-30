//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import ResizableSheet

struct InputHome {
    var tabIndex = 0
    var itemsInfomationOpacity: CGFloat = 0.0
    var basketInfomationOpacity: CGFloat = 0.0
    var isShowItemDetail: Bool = false
    var isPresentedEditItem: Bool = false
    var isShowSearchField: Bool = false
    var isShowSystemSideMenu: Bool = false
    var sideMenuBackGround: Bool = false
    var doCommerce: Bool = false
    var cartState: ResizableSheetState = .hidden
    var commerceState: ResizableSheetState = .hidden
}

struct HomeTabView: View {

    @StateObject var rootItemVM = ItemViewModel()
    @State private var inputHome: InputHome = InputHome()

    var body: some View {

        ZStack {

            TabView(selection: $inputHome.tabIndex) {

                LibraryView(itemVM: rootItemVM, inputHome: $inputHome)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                StockView(itemVM: rootItemVM, inputHome: $inputHome)
                    .tabItem {
                        Image(systemName: "shippingbox.fill")
                        Text("inventory")
                    }
                    .tag(1)

                ManageView(itemVM: rootItemVM, inputHome: $inputHome)
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Manage")
                    }
                    .tag(2)

            } // TabViewここまで

            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 30)
                    .overlay {
                        Text("アイテム情報が更新されました。")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .opacity(inputHome.itemsInfomationOpacity)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 30)
                    .overlay {
                        Text(inputHome.doCommerce ? "カート内の処理が確定しました。" : "カート内がリセットされました。")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .opacity(inputHome.basketInfomationOpacity)
                Spacer()
            }
            .offset(y: 80)
            .animation(.easeIn(duration: 0.2), value: inputHome.itemsInfomationOpacity)
            .animation(.easeIn(duration: 0.2), value: inputHome.basketInfomationOpacity)

            // Todo: 各タブごとにオプションが変わるボタン
            UsefulButton(inputHome: $inputHome)

            // sideMenu_background...
            Color.black
                .opacity(inputHome.sideMenuBackGround ? 0.25 : 0)
                .ignoresSafeArea()

            SystemSideMenu(itemVM: rootItemVM, inputHome: $inputHome)
                .offset(x: inputHome.isShowSystemSideMenu ? 0 : -UIScreen.main.bounds.width)

        } // ZStack
        .animation(.easeIn(duration: 0.2), value: inputHome.sideMenuBackGround)
        .animation(.spring(response: 0.2, blendDuration: 1.0), value: inputHome.isShowSystemSideMenu)
        .navigationBarBackButtonHidden()

        .onChange(of: inputHome.tabIndex) { newTabIndex in
            if newTabIndex == 0 || newTabIndex == 1 {
                if rootItemVM.tags.contains(where: {$0.tagName == "ALL"}) { return }
                rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
            }
            if newTabIndex == 2 || newTabIndex == 3 || inputHome.isPresentedEditItem {
                rootItemVM.tags.removeAll(where: {$0.tagName == "ALL"})
            }
        } // .onChange

        .onChange(of: inputHome.isPresentedEditItem) { present in
            if present {
                rootItemVM.tags.removeAll(where: { $0.tagName == "ALL" })
            } else {
                if rootItemVM.tags.contains(where: {$0.tagName == "ALL"}) { return }

                if inputHome.tabIndex == 0 || inputHome.tabIndex == 1 {
                    rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
                }
            }
        }

        .onChange(of: inputHome.isShowSystemSideMenu) { present in
            if present {
                rootItemVM.tags.removeAll(where: { $0.tagName == "ALL" })
                print("ALLタグを削除")
            } else {
                if rootItemVM.tags.contains(where: {$0.tagName == "ALL"}) { return }

                if inputHome.tabIndex == 0 || inputHome.tabIndex == 1 {
                    rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
                    print("ALLタグを追加")
                }
            }
        }

        .onAppear {
            if rootItemVM.tags.contains(where: {$0.tagName == "ALL"}) { return }
            rootItemVM.tags.insert(Tag(tagName: "ALL", tagColor: .gray), at: 0)
        }

    } // body
} // View

struct SystemSideMenu: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.editMode) var editMode

    @StateObject var itemVM: ItemViewModel
    @Binding var inputHome: InputHome

    struct InputSideMenu {
        var tag: Bool = false
        var account: Bool = false
        var help: Bool = false
        var editMode: EditMode = .inactive

    }

    @State private var inputSideMenu: InputSideMenu = InputSideMenu()
    @GestureState var dragOffset: CGFloat = 0.0

    var body: some View {

        ZStack {
            // Blur View...
            BlurView(style: .systemUltraThinMaterialDark)

            Color.customDarkGray1
                .opacity(0.7)
                .blur(radius: 15)

            Button {
                inputHome.isShowSystemSideMenu.toggle()
                inputHome.sideMenuBackGround.toggle()
            } label: {
                Image(systemName: "chevron.left.2")
                    .font(.title).opacity(0.5)
            }
            .foregroundColor(.white.opacity(0.6))
            .offset(x: UIScreen.main.bounds.width / 4,
                    y: -UIScreen.main.bounds.height / 3)

            VStack {
                VStack(alignment: .leading, spacing: 20) {

                    CircleIcon(photo: "cloth_sample1", size: 120)

                    Text("BUMP OF CHICKEN")
                        .font(.title3.bold()).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                Spacer(minLength: 40)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 60) {

                            SideMenuButton(open: $inputSideMenu.account,
                                           title: "アカウント", image: inputSideMenu.account ? "person.fill" : "person")

                            VStack(alignment: .leading) {
                                HStack {
                                    SideMenuButton(open: $inputSideMenu.tag,
                                                   title: "タグ", image: inputSideMenu.tag ? "tag.fill" : "tag")
                                    if inputSideMenu.tag {
                                        Button(action: {
                                            inputSideMenu.editMode = inputSideMenu.editMode.isEditing ? .inactive : .active
                                        }, label: {
                                            Text(inputSideMenu.editMode.isEditing ? "終了" : "編集")
                                                .opacity(itemVM.tags.count == 0 ? 0.0 : 1.0)
                                        })
                                        .padding(.leading, 30)
                                    }
                                }

                                if inputSideMenu.tag {

                                    Spacer(minLength: 0)

                                    List {

                                        ForEach(Array(itemVM.tags.enumerated()),
                                                id: \.offset) { offset, item in

                                            Text(item.tagName)
                                                .foregroundColor(.white)
                                                .listRowBackground(Color.clear)
                                                .overlay(alignment: .leading) {

                                                    Image(systemName: inputSideMenu.editMode.isEditing ?
                                                          "line.3.horizontal" : "highlighter")

                                                    .foregroundColor(.yellow).opacity(colorScheme == .dark ? 0.0 : 0.6)
                                                    .offset(x:inputSideMenu.editMode.isEditing ? 83 : 120)
                                                    .onTapGesture {
                                                        print(offset)
                                                        print("タグ編集ボタンタップ")
                                                    } // onTapGesture
                                                } // overlay
                                        }
                                                .onDelete(perform: rowRemove)
                                                .onMove(perform: rowReplace)
                                    } // List
                                    .environment(\.editMode, $inputSideMenu.editMode)
                                    .frame(width: 210, height: 40 * CGFloat(itemVM.tags.count - 1) + 100 )
                                    .animation(.easeIn(duration: 0.2), value: inputSideMenu.editMode)
                                    .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 0)))
                                    .scrollContentBackground(.hidden)
                                    .offset(x: -10)
                                    .overlay {

                                        VStack(spacing: 30) {
                                            Text("登録タグはありません")
                                                .foregroundColor(.white)
                                            Text("タグを追加 >>")
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    inputHome.isShowSystemSideMenu.toggle()
                                                    inputHome.sideMenuBackGround.toggle()
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                        inputHome.isPresentedEditItem.toggle()
                                                        print("あああああ")
                                                    }
                                                }
                                        }
                                        .opacity(itemVM.tags.count == 0 ? 0.8 : 0.0)
                                        .offset(y: 30)
                                    } // overlay

                                    Spacer(minLength: 0)

                                } // if tag...
                            } // VStack
                            SideMenuButton(open: $inputSideMenu.help,
                                           title: "ヘルプ", image: inputSideMenu.help
                                           ? "questionmark.circle.fill" : "questionmark.circle")

                        } // VStack(メニュー列全体)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .top])
                    } // ScrollView
            } // VStack
            .offset(y: UIScreen.main.bounds.height / 12)
        } // ZStack

        .clipShape(SideMenuShape())

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
                        withAnimation(.easeIn(duration: 0.2)) {
                            inputHome.isShowSystemSideMenu.toggle()
                            inputHome.sideMenuBackGround.toggle()
                        }
                    }
                }
        )
        .animation(.interpolatingSpring(mass: 0.8,
                                        stiffness: 100,
                                        damping: 80,
                                        initialVelocity: 0.1),value: dragOffset)

    } // body
        func rowRemove(offsets: IndexSet) {
            itemVM.tags.remove(atOffsets: offsets)
        }
        func rowReplace(_ from: IndexSet, _ to: Int) {
            itemVM.tags.move(fromOffsets: from, toOffset: to)
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
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))

                Image(systemName: "chevron.down")
                    .foregroundColor(.white).opacity(0.5)
                    .rotationEffect(Angle(degrees: open ? -180 : 0))
//                    .padding(.leading)
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

struct HomeTabView_Previews: PreviewProvider {

    static var previews: some View {

        var windowScene: UIWindowScene? {
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    return windowScene
                }
        var resizableSheetCenter: ResizableSheetCenter? {
                   windowScene.flatMap(ResizableSheetCenter.resolve(for:))
               }

            return HomeTabView()
            .environment(\.resizableSheetCenter, resizableSheetCenter)

    }
}
