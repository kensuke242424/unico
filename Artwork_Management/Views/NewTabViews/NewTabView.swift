//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet

struct InputTab {
    // 各設定Viewの表示を管理するプロパティ
    var showSideMenu       : Bool = false
    var showEntryAccount   : Bool = false
    var isActiveEditHome   : Bool = false
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
    var selectBackground: SelectBackground = .original
    
    /// タブViewのアニメーションを管理するプロパティ
    var selectionTab    : Tab = .home
    var animationTab    : Tab = .home
    var animationOpacity: CGFloat = 1
    var animationScale  : CGFloat = 1
    var scrollProgress  : CGFloat = .zero
    /// MEMO: ItemsTab内でDetailが開かれている間はTopNavigateBarを隠すためのプロパティ
    var reportShowDetail: Bool = false
    
    var showCart: ResizableSheetState = .hidden
    var showCommerce: ResizableSheetState = .hidden
}

struct NewTabView: View {
    
    @EnvironmentObject var navigationVM: NavigationViewModel
    @EnvironmentObject var logInVM: LogInViewModel
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tagVM : TagViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject var itemVM: ItemViewModel
    @StateObject var cartVM: CartViewModel
    
    /// View Properties
    @State private var inputTab = InputTab()

    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = false

    var body: some View {

        GeometryReader {
            let size = $0.size
            
            NavigationStack(path: $navigationVM.path) {
                
                VStack {
                    TabTopBarView()
                        .blur(radius: inputTab.checkBackgroundAnimation ||
                                      !inputTab.showSelectBackground ? 0 : 2)
                    
                    Spacer(minLength: 0)
                    
                    TabView(selection: $inputTab.selectionTab) {
                        NewHomeView(itemVM: itemVM, inputTab: $inputTab)
                            .tag(Tab.home)
                            .offsetX(inputTab.selectionTab == Tab.home) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(Tab.home.index))
                                let pageProgress = pageOffset / size.width
                                
                                inputTab.scrollProgress = max(min(pageProgress, 0), -CGFloat(Tab.allCases.count - 1))
                                inputTab.animationOpacity = 1 - -inputTab.scrollProgress
                            }
                        /// ホーム画面編集中は他のタブ要素を隠してタブ移動を無効化する
                        if !inputTab.isActiveEditHome {
                            NewItemsView(itemVM: itemVM,  cartVM: cartVM, inputTab: $inputTab)
                                .tag(Tab.item)
                                .offsetX(inputTab.selectionTab == Tab.item) { rect in
                                    let minX = rect.minX
                                    let pageOffset = minX - (size.width * CGFloat(Tab.item.index))
                                    let pageProgress = pageOffset / size.width

                                    inputTab.scrollProgress = max(min(pageProgress, 0), -CGFloat(Tab.allCases.count - 1))
                                    inputTab.animationOpacity = -inputTab.scrollProgress
                                }
                        }

                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .sheet(isPresented: $inputTab.showPickerView) {
                    PHPickerView(captureImage: $inputTab.captureBackgroundImage,
                                 isShowSheet : $inputTab.showPickerView)
                }
                .onChange(of: inputTab.selectionTab) { _ in
                    switch inputTab.selectionTab {
                    case .home:
                        withAnimation(.easeInOut(duration: 0.2)) {
                            inputTab.animationTab = .home
                        }
                    case .item:
                        withAnimation(.spring(response: 0.2)) {
                            inputTab.animationTab = .item
                        }
                    }
                }
                .background {
                    ZStack {
                        GeometryReader { proxy in
                            // ーーー　背景編集モード時　ーーー
                            if inputTab.showSelectBackground {
                                if inputTab.selectBackground == .original {
                                    if let captureNewImage = inputTab.captureBackgroundImage {
                                        Image(uiImage: captureNewImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: proxy.size.width, height: proxy.size.height)
                                            .blur(radius: inputTab.checkBackgroundAnimation ? 0 : 3, opaque: true)
                                            .ignoresSafeArea()
                                    } else {
                                        SDWebImageView(imageURL : teamVM.team?.backgroundURL,
                                                       width : proxy.size.width,
                                                       height: proxy.size.height)
                                        .blur(radius: inputTab.checkBackgroundAnimation ? 0 : 3, opaque: true)
                                    }

                                } else {
                                    Image(inputTab.selectBackground.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: proxy.size.width, height: proxy.size.height)
                                        .blur(radius: inputTab.checkBackgroundAnimation ? 0 : 3, opaque: true)
                                        .ignoresSafeArea()
                                }
                            // ーーー　通常時　ーーー
                            } else {
                                SDWebImageView(imageURL : teamVM.team?.backgroundURL,
                                               width : proxy.size.width,
                                               height: proxy.size.height)
                                .ignoresSafeArea()
                                .blur(radius: min((-inputTab.scrollProgress * 4), 4), opaque: true)
                                .blur(radius: homeVM.isActiveEdit ? 5 : 0, opaque: true)
                                .overlay {
                                    if homeVM.isActiveEdit {
                                        Color.black
                                            .opacity(0.4)
                                            .ignoresSafeArea()
                                    }
                                }
                            }
                        }
                    }
                } // background
                // チームの背景を変更編集するView
                .overlay {
                    if inputTab.showSelectBackground {

                        Color.black
                            .blur(radius: inputTab.checkBackgroundAnimation ||
                                          !inputTab.showSelectBackground ? 0 : 2)
                            .opacity(inputTab.checkBackgroundAnimation ? 0.1 : 0.5)
                            .ignoresSafeArea()
                            .onTapGesture(perform: {
                                // FIXME: これを入れておかないと下層のViewにタップが貫通してしまう🤔
                            })

                        SelectBackgroundView(inputTab: $inputTab)
                    }
                }
                /// サイドメニューView
                .overlay {
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
                /// チームへの招待View
                .overlay {
                    if teamVM.isShowSearchedNewMemberJoinTeam {
                        JoinUserDetectCheckView(teamVM: teamVM)
                            .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                    }
                }
                /// チームorユーザ情報の編集View
                .overlay {
                    if inputTab.selectedUpdateData == .user ||
                        inputTab.selectedUpdateData == .team {
                        UpdateTeamOrUserDataView(selectedUpdate: $inputTab.selectedUpdateData)
                            .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                    }
                }
                // お試しアカウントユーザーに本登録のインフォメーションを表示するView
                .overlay {
                    if inputTab.showEntryAccount {
                        UserEntryRecommendationView(isShow: $inputTab.showEntryAccount)
                    }
                }
                .ignoresSafeArea()

                /// NavigationStackによる遷移を管理します
                .navigationDestination(for: EditItemPath.self) { itemPath in
                    switch itemPath {
                    case .create:
                        NewEditItemView(itemVM: itemVM, passItem: nil)
                        
                    case .edit:
                        NewEditItemView(itemVM: itemVM,
                                        passItem: itemVM.items[cartVM.actionItemIndex])
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

    } // body
    @ViewBuilder
    func TabTopBarView() -> some View {
        GeometryReader {
            let size = $0.size
            let tabWidth = size.width / 3
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Text(tab == .home && inputTab.showSelectBackground ? "背景変更中" :
                            tab == .home && homeVM.isActiveEdit ? "編集中" :
                            tab.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .tracking(4)
                    .scaleEffect(inputTab.animationTab == tab ? 1.0 : 0.5)
                    .foregroundColor(applicationDarkMode ? .white : .black)
                    .opacity(inputTab.animationTab == tab ? 1 : 0.2)
                    .frame(width: tabWidth)
                    .contentShape(Rectangle())
                    .padding(.top, 60)
                }
            }
            .frame(width: CGFloat(Tab.allCases.count) * tabWidth)
            .padding(.leading, tabWidth)
            .offset(x: inputTab.scrollProgress * tabWidth)
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
                            .allowsHitTesting(inputTab.isActiveEditHome ? false : true)
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
                        .ignoresSafeArea()
                        .opacity(min(-inputTab.scrollProgress, 1))
                }
        )
    }

} // View

struct SelectBackgroundView: View {

    @EnvironmentObject var teamVM: TeamViewModel
    @Binding var inputTab: InputTab
//    @Binding var select: SelectBackground
//    @Binding var isShow: Bool = false
//    @Binding var captureImage: UIImage

    @State private var showContents: Bool = false
    @State private var showProgress: Bool = false

    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = false

    var body: some View {

        VStack(spacing: 30) {
            Spacer()

            if showContents {
                VStack(spacing: 15) {
                    Text("背景を選択してください")
                        .tracking(5)
                        .foregroundColor(.white)
                        .opacity(inputTab.checkBackgroundAnimation ? 0 : 0.8)

                    Text("チーム: \(teamVM.team?.name ?? "No Name")")
                        .tracking(3)
                        .font(.caption)
                        .foregroundColor(.white)
                        .opacity(inputTab.checkBackgroundAnimation ? 0 : 0.6)
                }
                .padding(.bottom, 5)

                ScrollBackgroundImages()
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                    .opacity(inputTab.checkBackgroundAnimation ? 0 : 1)

                VStack(spacing: 40) {
                    Button("保存") {
                        withAnimation(.easeIn(duration: 0.15)) { showProgress = true }
                        // 新しい背景が選択されていた場合、更新処理を実行する
                        Task {
                            do {
                                var updateBackgroundImage: UIImage?
                                if inputTab.selectBackground == .original {
                                    updateBackgroundImage = inputTab.captureBackgroundImage
                                } else {
                                    updateBackgroundImage = UIImage(named: inputTab.selectBackground.imageName)
                                }
                                if let updateBackgroundImage {
                                    let defaultImagePath = teamVM.team?.backgroundPath
                                    let resizedImage = teamVM.resizeUIImage(image: updateBackgroundImage,
                                                                            width: getRect().width * 4)
                                    let uploadImageData = await teamVM.uploadTeamImage(resizedImage)
                                    let _ = try await teamVM.updateTeamBackgroundImage(data: uploadImageData)
                                    // 新規背景画像の保存が完了したら、以前の背景データを削除
                                    let _ = await teamVM.deleteTeamImageData(path: defaultImagePath)
                                }
                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                    showContents = false
                                    showProgress = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                        inputTab.captureBackgroundImage = nil
                                        inputTab.selectBackground = .original
                                        inputTab.showSelectBackground = false
                                    }
                                }
                            } catch {
                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                    showContents = false
                                    showProgress = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                        inputTab.captureBackgroundImage = nil
                                        inputTab.selectBackground = .original
                                        inputTab.showSelectBackground = false
                                    }
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Label("キャンセル", systemImage: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                showContents.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                    inputTab.captureBackgroundImage = nil
                                    inputTab.selectBackground = .original
                                    inputTab.showSelectBackground = false
                                }
                            }
                        }
                }
                .opacity(inputTab.checkBackgroundAnimation ? 0 : 1)
                .overlay {
                    CustomizeToggleButtons()
                        .offset(x: getRect().width / 3)
                }
                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                .padding(.top, 50)
            } // if showContents

            Spacer().frame(height: 50)
        } // VStack
        .overlay {
            if showProgress {
                SavingProgressView()
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 1, blendDuration: 1)) {
                    showContents.toggle()
                }
            }
        }
    } // body

    @ViewBuilder
    func ScrollBackgroundImages() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(SelectBackground.allCases, id: \.self) { value in
                    Group {
                        if value == .original {
                            Group {
                                if let captureNewImage = inputTab.captureBackgroundImage {
                                    Image(uiImage: captureNewImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 250)
                                } else {
                                    SDWebImageView(imageURL: teamVM.team?.backgroundURL,
                                                   width: 120,
                                                   height: 250)
                                }
                            }
                            .overlay {
                                Button("写真を挿入") {
                                    inputTab.showPickerView.toggle()
                                }
                                .font(.footnote)
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            Image(value.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 250)
                        }
                    } // Group
                    .clipped()
                    .scaleEffect(inputTab.selectBackground == value ? 1.15 : 1.0)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                            .scaleEffect(inputTab.selectBackground == value ? 1.0 : 1.15)
                            .opacity(inputTab.selectBackground == value ? 1.0 : 0.0)
                            .offset(x: 15, y: -20)
                    }
                    .padding(.leading, value == .original ? 40 : 0)
                    .padding(.trailing, value == .sample4 ? 40 : 0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) {
                            inputTab.selectBackground = value
                        }
                    }
                }
            }
            .frame(height: 300)
        } // ScrollView
    }

    @ViewBuilder
    func CustomizeToggleButtons() -> some View {
        HStack {
            Spacer()
            ZStack {
                BlurView(style: .systemThickMaterial)
                    .frame(width: 90, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .opacity(0.8)

                VStack(spacing: 20) {
                    VStack {
                        Text("背景を確認").font(.footnote).offset(x: 15)
                        Toggle("", isOn: $inputTab.checkBackgroundToggle)
                    }
                    VStack {
                        Text("ダークモード").font(.footnote).offset(x: 15)
                        Toggle("", isOn: $applicationDarkMode)
                    }
                }
                .frame(width: 80)
                .padding(.trailing, 30)
                .onChange(of: inputTab.checkBackgroundToggle) { newValue in
                    if newValue {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            inputTab.checkBackgroundAnimation = true
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            inputTab.checkBackgroundAnimation = false
                        }
                    }
                }
            }
        }
    }
} // SelectBackgroundView

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
    }
}
