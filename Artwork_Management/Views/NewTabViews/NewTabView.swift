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
    var selectedUpdateData : SelectedUpdateData = .start
    
    /// NavigationPathによるエディット画面遷移時に渡す
    var selectedItem: Item?
    var selectedTag: Tag?
    
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
    
    @StateObject var itemVM: ItemViewModel
    @StateObject var cartVM: CartViewModel
    
    /// View Propertys
    @State private var inputTab = InputTab()

    var body: some View {

        GeometryReader {
            let size = $0.size
            
            NavigationStack(path: $navigationVM.path) {
                
                VStack {
                    TabTopBarView()
                    
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
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background {
                    ZStack {
                        GeometryReader { proxy in
                            SDWebImageView(imageURL : teamVM.team?.backgroundURL,
                                              width : proxy.size.width,
                                              height: proxy.size.height)
                                .ignoresSafeArea()
                                .blur(radius: min((-inputTab.scrollProgress * 4), 4), opaque: true)
                        }
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
                // お試しアカウントが本登録を行うView
                .overlay {
                    if inputTab.showEntryAccount {
                        UserEntryRecommendationView(isShow: $inputTab.showEntryAccount)
                    }
                }
                .ignoresSafeArea()
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
                        
                    case .deletedData:
                        DeletedView()
                    }
                }
                .navigationDestination(for: UpdateReportPath.self) { reportPath in
                    switch reportPath {
                    case .root:
                        UpdateReportView()
                    }
                }
            } // NavigationStack
        } // GeometryReader
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
//         アイテム取引かごのシート画面
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
                                halfSheetScroll: .main)
                        },
                        additional: {
                            CartItemsSheet(
                                cartVM: cartVM,
                                halfSheetScroll: .additional)
                            
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
        } // .resizableSheet
        
        // 決済リザルトのシート画面
        .resizableSheet($inputTab.showCommerce, id: "B") {builder in
            builder.content { _ in
                
                CommerceSheet(cartVM: cartVM,
                              inputTab: $inputTab,
                              teamID: teamVM.team!.id)
                
            } // builder.content
            .supportedState([.medium])
            .sheetBackground { _ in
                Color.white
                .opacity(0.95)
            }
            .background { _ in
                EmptyView()
            }
        } // .resizableSheet
        
        
    } // body
    @ViewBuilder
    func TabTopBarView() -> some View {
        GeometryReader {
            let size = $0.size
            let tabWidth = size.width / 3
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Text(tab.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .tracking(4)
                        .scaleEffect(inputTab.animationTab == tab ? 1.0 : 0.5)
                        .foregroundColor(inputTab.animationTab == tab ? .primary : .gray)
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
    
    func SelectBackgroundViews() -> some View {
        VStack(spacing: 30) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(SelectBackground.allCases, id: \.self) { value in
                        Group {
                            if value == .original {
                                Image(uiImage: inputLogIn.captureBackgroundImage ?? UIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 250)
                                    .border(.blue, width: 1)
                                    .overlay {
                                        Button("写真を挿入") {
                                            inputLogIn.isShowPickerView.toggle()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        
                                    }
                            } else {
                                Image(value.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 250)
                            }
                        }
                        .clipped()
                        .scaleEffect(inputLogIn.selectBackground == value ? 1.2 : 1.0)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "checkmark.seal.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.green)
                                .frame(width: 30, height: 30)
                                .scaleEffect(inputLogIn.selectBackground == value ? 1.0 : 1.2)
                                .opacity(inputLogIn.selectBackground == value ? 1.0 : 0.0)
                                .offset(x: 20, y: -30)
                        }
                        .padding(.leading, value == .original ? 40 : 0)
                        .padding(.trailing, value == .sample4 ? 40 : 0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5)) {
                                inputLogIn.selectBackground = value
                            }
                        }
                    }
                }
                .frame(height: 310)
            }
        } // VStack
        .opacity(inputLogIn.checkBackgroundOpacity)
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
    }
}
