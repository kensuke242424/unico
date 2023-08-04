//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet
import Introspect

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
    var selectionTab    : Tab = .home
    /// タブの切り替えによるアニメーションの状態を管理するプロパティ
    var animationTab    : Tab = .home
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

struct NewTabView: View {
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var localNotificationVM: LocalNotificationViewModel
    @EnvironmentObject var teamNotificationVM: TeamNotificationViewModel
    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tagVM : TagViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

    @StateObject var itemVM: ItemViewModel
    @StateObject var cartVM: CartViewModel
    
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
                        NewHomeView(itemVM: itemVM, inputTab: $inputTab)
                            .tag(Tab.home)

                        NewItemsView(itemVM: itemVM,  cartVM: cartVM, inputTab: $inputTab)
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
                                BlurMaskingImageView(imageURL: userVM.currentTeamBackground?.imageURL)
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
                    SystemSideMenu(itemVM: itemVM, inputTab: $inputTab)
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
                /// チーム招待、チーム編集、ユーザー編集View
                .overlay {
                    Group {
                        if teamVM.isShowSearchedNewMemberJoinTeam {
                            JoinUserDetectCheckView(teamVM: teamVM)
                                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                        }
                        if inputTab.showUpdateTeam {
                            UpdateTeamDataView(show: $inputTab.showUpdateTeam)
                                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                        }
                        if inputTab.showUpdateUser {
                            UpdateUserDataView(show: $inputTab.showUpdateUser)
                                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                        }
                    }
                }
                // お試しアカウントユーザーに本登録のインフォメーションを表示するView
                .overlay {
                    if inputTab.showEntryAccount {
                        UserEntryRecommendationView(isShow: $inputTab.showEntryAccount)
                    }
                }
                .ignoresSafeArea()
                /// カスタム通知ビュー
                .overlay {
                    Group {
                        if teamNotificationVM.show {
                            TeamNotificationView()
                        }
                        LocalNotificationView()
                    }
                }
                .navigationDestination(for: SystemPath.self) { systemPath in
                    switch systemPath {
                    case .root:
                        SystemView(itemVM: itemVM)
                    }
                }
                .navigationDestination(for: UpdateReportPath.self) { reportPath in
                    switch reportPath {
                    case .root:
                        UpdateReportView()
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
                        Text("カート内のアイテム")
                            .foregroundColor(.black)
                            .font(.headline)
                            .fontWeight(.black)
                            .opacity(0.6)
                        Spacer()
                        Button(
                            action: {
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
                            
                            Spacer()
                                .frame(height: 100)
                        }
                    )
                    Spacer()
                        .frame(height: 80)
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
                              teamID: teamVM.team!.id,
                              memberColor: userVM.memberColor)
                .environmentObject(teamNotificationVM)
                .environmentObject(teamVM)
                
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
        .onChange(of: cartVM.resultCartAmount) {
            [beforeCart = cartVM.resultCartAmount] afterCart in
            
            if beforeCart == 0 {
                print("カートにアイテム追加を検知。シートを表示")
                inputTab.showCommerce = .medium
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    inputTab.showCart = .medium
                }
            }
            if afterCart == 0 {
                print("カートアイテムが空になったのを検知。シートを閉じる")
                inputTab.showCart = .hidden
                inputTab.showCommerce = .hidden
            }
        }
        .onAppear {
            tagVM.setFirstActiveTag()
            teamNotificationVM.listener(id: teamVM.teamID)
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
                    .padding(.top, 60)
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
                        Button {
                            /// アイテム追加エディット画面に遷移
                            withAnimation(.spring(response: 0.4)) {
                                navigationVM.path.append(EditItemPath.create)
                            }
                        } label: {
                            Image(systemName: "shippingbox.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.primary)
                                .frame(width: 30, height: 30)
                                .opacity(inputTab.animationOpacity)
                        }
                        .transition(.asymmetric(
                            insertion: AnyTransition.opacity.combined(with: .offset(x: 20, y: 0)),
                            removal: AnyTransition.opacity.combined(with: .offset(x: 20, y: 0))
                        ))
                    }
                } // HStack
                .padding(.horizontal, 20)
                .padding(.top, 60)
            }
        } // Geometry
        .frame(height: 100)
        .background(
            Color.clear
                .overlay {
                    BlurView(style: .systemUltraThinMaterial)
                        .opacity(inputTab.animationTab == .home ? 0 : 1)
                        .ignoresSafeArea()
                }
        )
    }

} // View

struct NewTabView_Previews: PreviewProvider {

    static var previews: some View {

        var windowScene: UIWindowScene? {
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene
                    return windowScene
                }
        var resizableSheetCenter: ResizableSheetCenter? {
                   windowScene.flatMap(ResizableSheetCenter.resolve(for:))
               }

        return NewTabView(itemVM: ItemViewModel(), cartVM: CartViewModel())
            .environment(\.resizableSheetCenter, resizableSheetCenter)
            .environmentObject(NavigationViewModel())
            .environmentObject(LogInViewModel())
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(TagViewModel())
            .environmentObject(BackgroundViewModel())
    }
}
