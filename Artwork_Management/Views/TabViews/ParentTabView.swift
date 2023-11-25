//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet
import Introspect

struct ParentTabView: View {

    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var logInVM: AuthViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var itemVM: ItemViewModel
    @EnvironmentObject var tagVM : TagViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

    @EnvironmentObject var logVM: LogViewModel
    @EnvironmentObject var momentLogVM: MomentLogViewModel

    @StateObject var cartVM: CartViewModel

    @StateObject var homeVM = HomeViewModel()

    /// View Properties
    @State private var inputTab = InputTab()

    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = true

    var body: some View {

        GeometryReader {
            let size = $0.size
            
            NavigationStack(path: $navigationVM.path) {

                VStack {
                    TabTopBarView()
                        .blur(radius: backgroundVM.checkMode ||
                                      !backgroundVM.showEdit ? 0 : 2)
                    
                    Spacer(minLength: 0)
                    
                    TabView(selection: $inputTab.selectionTab) {
                        HomeTabView(homeVM: homeVM, inputTab: $inputTab)
                            .tag(Tab.home)

                        ItemTabView(cartVM: cartVM, inputTab: $inputTab)
                            .tag(Tab.item)
                    } // TabView
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .introspectScrollView { scrollView in
                         scrollView.isDirectionalLockEnabled = true
                         scrollView.bounces = false
                    }
                }
                /// 背景編集でオリジナル画像を選択時に発火
                .sheet(isPresented: $backgroundVM.showPicker) {
                    PHPickerView(captureImage: $backgroundVM.croppedUIImage,
                                 isShowSheet : $backgroundVM.showPicker)
                }
                // お試しアカウントユーザーに本登録のインフォメーションを表示するView
                .sheet(isPresented: $inputTab.showEntryAccount) {
                    UserEntryRecommendationView(isShow: $inputTab.showEntryAccount)
                }
                /// 新規チームへの加入が検知されたら、新規加入報告ビューを表示
                .task(id: userVM.newJoinedTeam) {
                    if logInVM.rootNavigation == .join { return }
                    guard let _ = userVM.newJoinedTeam else { return }

                    print("=========他チームからのチーム加入承諾を検知=========")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            userVM.showJoinedTeamInformation = true
                            hapticSuccessNotification()
                        }
                    }
                }
                /// TabViewに紐づけているプロパティをアニメーションのトリガーとして使えないため
                ///  タブのステートとタブ切り替えによるアニメーションのステートを切り分けている
                .onChange(of: inputTab.selectionTab) { _ in
                    switch inputTab.selectionTab {
                    case .home:
                        withAnimation(.spring(response: 0.4)) {
                            inputTab.animationTab = .home
                        }
                    case .item:
                        withAnimation(.spring(response: 0.4)) {
                            inputTab.animationTab = .item
                        }
                    }
                }
                /// チームルームの背景
                .background {
                    ZStack {
                        GeometryReader { proxy in
                            Color.black.ignoresSafeArea()
                            // チーム背景編集による選択画像URLが存在する場合、そちらを優先して背景表示する
                            SDWebImageBackgroundView(
                                imageURL: backgroundVM.selectBackground?.imageURL ??
                                userVM.currentTeamBackground?.imageURL,
                                width: proxy.size.width,
                                height: proxy.size.height
                            )
                            .ignoresSafeArea()
                            .blur(radius: homeVM.isActiveEdit ? 5 : 0, opaque: true)
                            .blur(radius: inputTab.pressingAnimation ? 6 : 0, opaque: true)
                            .blur(radius: backgroundVM.showEdit && !backgroundVM.checkMode ? 6 : 0, opaque: true)
                            // タブのスワイプ遷移時と背景へのblurが重なると、動作が重くなる
                            // オーバーレイでブラー処理済み背景を重ねる
                            .overlay {
                                BlurMaskingImageView(
                                    imageURL: backgroundVM.selectBackground?.imageURL ??
                                    userVM.currentTeamBackground?.imageURL)
                                .opacity(inputTab.animationTab == .item ? 1 : 0)
                            }
                            .overlay {
                                if homeVM.isActiveEdit {
                                    Color.black.opacity(0.4)
                                        .ignoresSafeArea()
                                }
                            }
                        }
                    }
                } // background
                // チームの背景を変更編集するView
                .overlay {
                    if backgroundVM.showEdit {

                        Color.black
                            .blur(radius: backgroundVM.checkMode ||
                                  !backgroundVM.showEdit ? 0 : 2)
                            .opacity(backgroundVM.checkMode ? 0.1 : 0.5)
                            .ignoresSafeArea()
                            .onTapGesture(perform: {
                                // FIXME: これを入れておかないと下層のViewにタップが貫通してしまう🤔
                            })

                        EditTeamBackgroundView()
                            .offset(y: 40)
                    }
                }
                /// サイドメニューView
                .overlay {
                    if inputTab.showSideMenu {
                        Color.black.opacity(0.3).ignoresSafeArea()
                            .onTapGesture(perform: {
                                withAnimation(.spring(response: 0.5)) {
                                    inputTab.showSideMenu.toggle()
                                }
                            })
                    }
                    SystemSideMenu(homeVM: homeVM, inputTab: $inputTab)
                        .offset(x: inputTab.showSideMenu ? 0 : -size.width)
                }
                /// 🏷タグの追加や編集を行うView
                .overlay {
                    if tagVM.showEdit {
                        Color.black
                            .opacity(0.7)
                            .ignoresSafeArea()
                        EditTagView(passTag: $inputTab.selectedTag,
                                    show   : $tagVM.showEdit)
                        .transition(AnyTransition.opacity.combined(with: .offset(y: 50)))
                    }
                }
                /// チーム招待、チーム編集、ユーザー編集関連のView
                .overlay {
                    Group {
                        if teamVM.isShowSearchedNewMemberJoinTeam {
                            JoinUserDetectCheckView(teamVM: teamVM)
                                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                        }
                        if inputTab.showUpdateTeam {
                            TeamProfileEditView(show: $inputTab.showUpdateTeam)
                                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                        }
                        if inputTab.showUpdateUser {
                            UserProfileEditView(show: $inputTab.showUpdateUser)
                                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                        }
                        if userVM.showJoinedTeamInformation {
                            JoinedTeamInformationView(presented: $userVM.showJoinedTeamInformation)
                                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                        }
                    }
                }

                .ignoresSafeArea()
                /// カスタム通知ビュー
                .overlay {
                    Group {
                        NotificationView()
                        MomentLogView()
                    }
                }
                .navigationDestination(for: SystemPath.self) { systemPath in
                    switch systemPath {
                    case .root:
                        SystemView()
                    }
                }
                .navigationDestination(for: ApplicationSettingPath.self) { settingPath in
                    switch settingPath {
                    case .root:
                        ApplicationSettingView()
                    }
                }
                .navigationDestination(for: SystemAccountPath.self) { accountPath in
                    switch accountPath {
                    case .root:
                        AccountSystemView()
                        
                    case .defaultEmailCheck:
                        DefaultEmailCheckView()
                        
                    case .updateEmail:
                        UpdateAddressView()
                        
                    case .successUpdateEmail:
                        SuccessUpdateAddressView()
                        
                    case .deleteAccount:
                        DeleteAccountView()

                    case .excutionDelete:
                        DeletingView()
                        
                    case .deletedAccount:
                        DeletedView()
                    }
                }
            } // NavigationStack
        } // GeometryReader
        // 🧺アイテム取引かごのシート画面
        .resizableSheet($inputTab.showCart, id: "A") { builder in
            builder.content { context in
                
                VStack {
                    Spacer(minLength: 0)
                    GrabBar()
                        .foregroundColor(.black)
                    Spacer(minLength: 0)
                    
                    HStack(alignment: .bottom) {
                        Text("処理中のアイテム")
                            .foregroundColor(.black)
                            .font(.headline)
                            .fontWeight(.black)
                            .opacity(0.6)
                        Spacer()
                        Button(
                            action: {
                                inputTab.showCart = .hidden
                                inputTab.showCommerce = .hidden
                                cartVM.resetCart()
                            },
                            label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("全て削除")
                                        .font(.callout)
                                }
                                .foregroundColor(.red)
                            }
                        ) // Button
                    } // HStack
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 8)
                    
                    ResizableScrollView(
                        context: context,
                        main: {
                            CartItemsSheet(
                                cartVM: cartVM,
                                halfSheetScroll: .main,
                                memberColor: userVM.memberColor)
                        },
                        additional: {
                            CartItemsSheet(
                                cartVM: cartVM,
                                halfSheetScroll: .additional,
                                memberColor: userVM.memberColor)

                            // 全画面リスト表示時の下部の余白
                            Spacer()
                                .frame(height: 100)
                        }
                    )
                    // ミディアム表示時において、決済シートの重なり幅の分だけ、カートシートを上にずらす
                    Spacer()
                        .frame(height: userDeviseSize == .small ? 70 :  80)
                } // VStack
            } // builder.content
            .sheetBackground { _ in
                Color.white
                .opacity(0.95)
                .blur(radius: 1)
            }
            .background { _ in
                EmptyView()
            }
        }
        // 🧺決済リザルトのシート画面
        .resizableSheet($inputTab.showCommerce, id: "B") {builder in
            builder.content { _ in

                CommerceSheet(cartVM: cartVM,
                              inputTab: $inputTab,
                              teamID: teamVM.team?.id ?? "",
                              memberColor: userVM.memberColor)
                // MEMO: resizableSheet内でEnvironmentObjectを使うには
                // 再度参照を渡す必要がある↓
                .environmentObject(logVM)
                .environmentObject(teamVM)
                .environmentObject(userVM)
            } // builder.content
            .supportedState([.medium])
            .sheetBackground { _ in
                Color.white
                .opacity(0.95)
            }
            .background { _ in
                EmptyView()
            }
        }
        /// カートの状態を監視し、アイテムが入ったらカートビューを表示する。
        .onChange(of: cartVM.resultCartAmount) {
            [beforeCart = cartVM.resultCartAmount] afterCart in
            
            if beforeCart == 0 {
                inputTab.showCommerce = .medium
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    inputTab.showCart = .medium
                }
            }
            if afterCart == 0 {
                inputTab.showCart = .hidden
                inputTab.showCommerce = .hidden
            }
        }
        /// カートの精算実行を監視する
        .onChange(of: cartVM.doCommerce) { doCommerce in
            if doCommerce {
                DispatchQueue.main.async {
                    inputTab.showCart = .hidden
                    inputTab.showCommerce = .hidden
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cartVM.resetCart()
                }
            }
        }
        /// 最後にログインしたチームのId「lastLogin」
        .onAppear {
            tagVM.setFirstActiveTag()
            // 通知リスナーはタブビュー生成時にスタート
            notificationVM.listener(id: userVM.user?.lastLogIn)
        }
        /// 現在のデータリスナー群をリセットする
        .onDisappear {
            removeListeners()
        }
    } // body
    @ViewBuilder
    /// タブビューのカスタムトップナビゲーションバー
    func TabTopBarView() -> some View {
        GeometryReader {
            let size = $0.size
            let tabWidth = size.width / 3
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Text(tab == .home && backgroundVM.showEdit ? "背景変更中" :
                            tab == .home && homeVM.isActiveEdit ? "編集中" :
                            tab.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .tracking(4)
                    .scaleEffect(inputTab.animationTab == tab ? 1.0 : 0.5)
                    .foregroundColor(applicationDarkMode ? .white : .black)
                    .opacity(inputTab.animationTab == tab ? 1 : 0.5)
                    .frame(width: tabWidth)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: {
                        if tab == .home && inputTab.selectionTab == .item {
                            inputTab.selectionTab = .home
                        } else if tab == .item && inputTab.selectionTab == .home {
                            inputTab.selectionTab = .item
                        }
                    })
                }
            }
            .frame(width: CGFloat(Tab.allCases.count) * tabWidth)
            .padding(.leading, tabWidth)
            .offset(x: CGFloat(inputTab.animationTab.index) * -tabWidth)
            .overlay {
                HStack {
                    /// Homeタブに移動した時に表示するチームアイコン
                    if inputTab.animationTab == .home {
                        SDWebImageCircleIcon(imageURL: teamVM.team?.iconURL, width: 50, height: 50)
                            .transition(.asymmetric(
                                insertion: AnyTransition.opacity.combined(with: .offset(x: -20, y: 0)),
                                removal: AnyTransition.opacity.combined(with: .offset(x: -20, y: 0))
                            ))
                            .opacity(inputTab.animationOpacity)
                            .onTapGesture {
                                // TODO: サイドメニュー表示
                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                    inputTab.showSideMenu.toggle()
                                }
                            }
                            /// 匿名使用中に表示するラベル
                            .overlay(alignment: .bottom) {
                                if userVM.isAnonymous {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.black.gradient)
                                            .frame(width: 50, height: 20)
                                        Text("お試し中")
                                            .foregroundColor(.orange)
                                            .font(.caption2)
                                    }
                                    .opacity(inputTab.animationOpacity)
                                    .offset(y: 30)
                                }
                            }
                            .allowsHitTesting(homeVM.isActiveEdit ? false : true)
                    }
                    Spacer()
                    /// Itemタブに移動した時に表示するアイテム追加タブボタン
                    if inputTab.animationTab == .item && !inputTab.reportShowDetail {
                        // -- 新規アイテム追加ボタン --
                        Button {
                            // アイテム追加エディット画面に遷移
                            withAnimation(.spring(response: 0.4)) {
                                navigationVM.path.append(EditItemPath.create)
                            }
                        } label: {
                            Image(systemName: "shippingbox.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .overlay(alignment: .topTrailing) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10, height: 10)
                                        .offset(x: 5, y: -5)
                                }
                                .foregroundColor(.primary)
                                .opacity(inputTab.animationOpacity)
                        }
                        .transition(.asymmetric(
                            insertion: AnyTransition.opacity.combined(with: .offset(x: 20, y: 0)),
                            removal: AnyTransition.opacity.combined(with: .offset(x: 20, y: 0))
                        ))
                    }
                } // HStack
                .padding(.horizontal, 20)
            }
            .padding(.top, userDeviseSize == .small ? 35 : 60)
        } // Geometry
        .frame(height: userDeviseSize == .small ? 70 : 100)
        .background(
            Color.clear
                .overlay {
                    BlurView(style: .systemUltraThinMaterial)
                        .opacity(inputTab.animationTab == .home ? 0 : 1)
                        .ignoresSafeArea()
                }
        )
    }

    /// タブビューの破棄時に、現在のリスナーをデタッチするメソッド。
    /// チーム変更時は、前チームへのリスナーをデタッチしておく必要がある。
    /// userListenerだけは、参照ドキュメントは変化しないため、リスナーを残す
    func removeListeners() {
        userVM.removeListener()
        teamVM.removeListener()
        tagVM.removeListener()
        itemVM.removeListener()
        notificationVM.removeListener()
    }
} // View

struct InputTab {
    // 各設定Viewの表示を管理するプロパティ
    var showSideMenu       : Bool = false
    var showEntryAccount   : Bool = false
    var showUpdateTeam     : Bool = false
    var showUpdateUser     : Bool = false
    var isActiveEditHome   : Bool = false
    var pressingAnimation  : Bool = false
    var selectedUpdateData : SelectedUpdateData = .start

    /// NavigationPathによるエディット画面遷移時に渡す
    var selectedItem: Item?
    var selectedTag: Tag?

    /// バックグラウンドを管理するプロパティ
    var teamBackground: URL?
    var captureBackgroundImage: UIImage?
    var showPickerView: Bool = false
    var showSelectBackground: Bool = false
    var checkBackgroundToggle: Bool = false
    var checkBackgroundAnimation: Bool = false
    var selectBackgroundCategory: BackgroundCategory = .music
    var selectedBackgroundImage: UIImage?

    /// タブの選択状態を管理するプロパティ
    var selectionTab    : Tab = .item
    /// タブの切り替えによるアニメーションの状態を管理するプロパティ
    var animationTab    : Tab = .item
    var animationOpacity: CGFloat = 1
    var animationScale  : CGFloat = 1
    var scrollProgress  : CGFloat = .zero
    var tabIndex: Int {
        switch selectionTab {
        case .home:
            return 0
        case .item:
            return 1
        }
    }
    /// MEMO: ItemsTab内でDetailが開かれている間はTopNavigateBarを隠すためのプロパティ
    var reportShowDetail: Bool = false

    var showCart: ResizableSheetState = .hidden
    var showCommerce: ResizableSheetState = .hidden
}
