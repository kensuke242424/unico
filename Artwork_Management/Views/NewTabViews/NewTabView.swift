//
//  NewHomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI
import ResizableSheet

enum NavigationPath {
    case create, edit, system
}

struct InputTab {
    /// Navigation遷移を管理するプロパティ
    var path: [NavigationPath] = []
    /// NavigationPathによるエディット画面遷移時に渡す
    var selectedItem: Item?
    
    /// タブViewアニメーションを管理するプロパティ
    var selectionTab: Tab = .item
    var animationTab: Tab = .item
    var animationOpacity: CGFloat = 1
    var animationScale: CGFloat = 1
    var scrollProgress: CGFloat = .zero
    
    var showEditSheet: Bool = false
    
    /// ItemsViewでユーザーが選択したアイテムが渡されるプロパティ
}

struct NewTabView: View {
    
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM : TagViewModel
    /// View Propertys
    @State private var inputTab = InputTab()

    var body: some View {

        GeometryReader {
            let size = $0.size
            
            NavigationStack(path: $inputTab.path) {
                
                VStack {
                    
                    TabTopBarView()
                    
                    Spacer(minLength: 0)
                    
                    TabView(selection: $inputTab.selectionTab) {
                        NewHomeView(teamVM: teamVM, itemVM: itemVM, inputTab: $inputTab)
                            .tag(Tab.home)
                            .offsetX(inputTab.selectionTab == Tab.home) { rect in
                                let minX = rect.minX
                                let pageOffset = minX - (size.width * CGFloat(Tab.home.index))
                                let pageProgress = pageOffset / size.width
                                
                                inputTab.scrollProgress = max(min(pageProgress, 0), -CGFloat(Tab.allCases.count - 1))
                                inputTab.animationOpacity = 1 - -inputTab.scrollProgress
                            }
                        
                        NewItemsView(teamVM: teamVM, userVM: userVM, itemVM: itemVM, tagVM: tagVM, inputTab: $inputTab)
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
                            Image("background_1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .ignoresSafeArea()
                                .blur(radius: min((-inputTab.scrollProgress * 4), 4), opaque: true)
                        }
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
                .sheet(isPresented: $inputTab.showEditSheet) {
                    NewEditItemView(teamVM  : teamVM,
                                    userVM  : userVM,
                                    itemVM  : itemVM,
                                    tagVM   : tagVM,
                                    passItem: nil)
                }
                
                /// NavigationStackによる遷移を管理します
                .navigationDestination(for: NavigationPath.self) { path in
                    
                    switch path {
                    case .create:
                        
                        NewEditItemView(teamVM  : teamVM,
                                        userVM  : userVM,
                                        itemVM  : itemVM,
                                        tagVM   : tagVM,
                                        passItem: nil)
                        
                    case .edit:
                        NewEditItemView(teamVM  : teamVM,
                                        userVM  : userVM,
                                        itemVM  : itemVM,
                                        tagVM   : tagVM,
                                        passItem: inputTab.selectedItem)
                        
                    case .system:
                        Text("システム画面")
                    }
                    
                }
            } // NavigationStack
        } // GeometryReader
        

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
                        Circle()
                            .frame(width: 35, height: 35)
                            .transition(.asymmetric(
                                insertion: AnyTransition.opacity.combined(with: .offset(x: -20, y: 0)),
                                removal: AnyTransition.opacity.combined(with: .offset(x: -20, y: 0))
                            ))
                            .opacity(inputTab.animationOpacity)
                    }
                    Spacer()
                    /// Itemタブに移動した時に表示するアイテム追加タブボタン
                    if inputTab.animationTab == .item {
                        Button {
                            /// アイテム追加エディット画面に遷移
                            ///  追加ボタンなので、selectedItemはnilを入れておく
                            withAnimation(.spring(response: 0.4)) {
                                inputTab.path.append(.edit)
//                                inputTab.showEditSheet.toggle()
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

        return NewTabView(teamVM: TeamViewModel(),
                          userVM: UserViewModel(),
                          itemVM: ItemViewModel(),
                          tagVM : TagViewModel())
            .environment(\.resizableSheetCenter, resizableSheetCenter)

    }
}
