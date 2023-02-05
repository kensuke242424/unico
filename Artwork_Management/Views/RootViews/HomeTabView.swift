//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import ResizableSheet

enum EditStatus {
    case create
    case update
}

enum UpdateImageStatus {
    case item, header, icon
}

struct InputHome {
    var switchElement: ElementStatus = .stock
    var homeTabIndex: Int = 0
    var actionItemIndex: Int = 0
    var selectCaptureImage: UIImage? = nil
    var itemsInfomationOpacity: CGFloat = 0.0
    var basketInfomationOpacity: CGFloat = 0.0
    var showErrorFetchImage: Bool = false
    var isShowProgress: Bool = false
    var isShowItemDetail: Bool = false
    var isShowHomeTopNavigation: Bool = true
    var isPresentedEditItem: Bool = false
    var isOpenEditTagSideMenu: Bool = false
    // Task: チーム切り替えハーフシートモーダルの作成
    var isOpenChangedTeamSheet: Bool = false
    var isShowSearchField: Bool = false
    var isShowSystemSideMenu: Bool = false
    var isShowManageCustomSideMenu: Bool = false
    var editTagSideMenuBackground: Bool = false
    var sideMenuBackGround: Bool = false
    var isShowSelectImageSheet: Bool = false
    var doCommerce: Bool = false
    var doItemEdit: Bool = false
    var editItemStatus: EditStatus = .create
    var selectedUpdateData: SelectedUpdateData = .start
    var updateImageStatus: UpdateImageStatus = .item
    var cartHalfSheet: ResizableSheetState = .hidden
    var commerceHalfSheet: ResizableSheetState = .hidden
}

struct InputImage {
    var userColor: Color = .gray
}

struct HomeTabView: View {

    @StateObject var logInVM: LogInViewModel
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel
    @State private var inputHome: InputHome = InputHome()
    @State private var inputImage: InputImage = InputImage()
    @State private var inputSideMenu: InputSideMenu = InputSideMenu()
    @State private var inputTag: InputTagSideMenu = InputTagSideMenu()
    @State private var inputManage: InputManageCustomizeSideMenu = InputManageCustomizeSideMenu()
    @State private var cartAvertOffsetY: CGFloat = 0.0

    var body: some View {

        ZStack {

            TabView(selection: $inputHome.homeTabIndex) {

                LibraryView(teamVM: teamVM,
                            userVM: userVM,
                            itemVM: itemVM,
                            tagVM: tagVM,
                            inputHome: $inputHome,
                            inputImage: $inputImage)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                StockView(teamVM: teamVM,
                          userVM: userVM,
                          itemVM: itemVM,
                          tagVM: tagVM,
                          inputHome: $inputHome,
                          inputImage: $inputImage)
                    .tabItem {
                        Image(systemName: "shippingbox.fill")
                        Text("inventory")
                    }
                    .tag(1)

                ManageView(teamVM: teamVM,
                           userVM: userVM,
                           itemVM: itemVM,
                           tagVM: tagVM,
                           inputHome: $inputHome,
                           inputImage: $inputImage,
                           inputManage: $inputManage)
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Manage")
                    }
                    .tag(2)

            } // TabViewここまで

            Group {

                UsefulButton(inputHome: $inputHome)
                    .offset(x: UIScreen.main.bounds.width / 3,
                            y: UIScreen.main.bounds.height / 3 - 5)
                    .offset(y: cartAvertOffsetY)

                ElementSwitchingPickerView(switchElement: $inputHome.switchElement, tabIndex: $inputHome.homeTabIndex)
                    .offset(y: getRect().height / 2 - getSafeArea().bottom - 110)
                    .offset(y: cartAvertOffsetY)

                NavigationHeader(inputHome: $inputHome, photoURL: userVM.user!.iconURL)
                    .opacity(!inputHome.isShowHomeTopNavigation &&
                             inputHome.homeTabIndex == 0 &&
                             teamVM.team!.headerURL != nil
                             ? 0.0 : 1.0)
                    .offset(y: -getRect().height / 2 + getSafeArea().top + 15)
                    .padding(.horizontal, 20)
            }

            if inputHome.homeTabIndex == 2 {
                ManageCustomizeSideMenu(inputManage: $inputManage, isOpen: $inputHome.isShowManageCustomSideMenu)
                    .offset(x: getRect().width, y: -40)
                    .offset(x: inputHome.isShowManageCustomSideMenu ? -170 : 50)
                    .opacity(inputHome.homeTabIndex == 2 ? 1.0 : 0.0)
            }

            if inputHome.isShowItemDetail {
                ShowsItemDetail(itemVM: itemVM,
                                inputHome: $inputHome,
                                item: itemVM.items[inputHome.actionItemIndex],
                                teamID: teamVM.team!.id)
            }

            // side menu contents...
            Group {

                // sideMenu_background...
                Color.black
                    .ignoresSafeArea()
                    .opacity(inputHome.sideMenuBackGround ? 0.4 : 0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                            inputHome.isShowSystemSideMenu.toggle()
                        }
                        withAnimation(.easeIn(duration: 0.2)) {
                            inputHome.sideMenuBackGround.toggle()
                        }
                    }

                SystemSideMenu(teamVM: teamVM,
                               userVM: userVM,
                               itemVM: itemVM,
                               tagVM: tagVM,
                               logInVM: logInVM,
                               inputHome: $inputHome,
                               inputImage: $inputImage,
                               inputTag: $inputTag,
                               inputSideMenu: $inputSideMenu)
                    .offset(x: inputHome.isShowSystemSideMenu ? 0 : -UIScreen.main.bounds.width)

                if inputHome.selectedUpdateData != .start {
                    UpdateTeamOrUserDataView(selectedUpdate: $inputHome.selectedUpdateData,
                                             userVM: userVM,
                                             teamVM: teamVM)
                }

                // sideMenu_background...
                Color.black
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                    .opacity(inputHome.editTagSideMenuBackground ? 0.7 : 0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                            inputHome.editTagSideMenuBackground.toggle()
                        }
                        withAnimation(.easeIn(duration: 0.2)) {
                            inputHome.isOpenEditTagSideMenu.toggle()
                        }
                    }

                // Open TagSideMenu...
                SideMenuEditTagView(itemVM: itemVM,
                                    tagVM: tagVM,
                                    inputHome: $inputHome,
                                    inputTag: $inputTag,
                                    defaultTag: inputTag.tagSideMenuStatus == .create ? nil : inputSideMenu.selectTag,
                                    tagSideMenuStatus: inputTag.tagSideMenuStatus,
                                    teamID: teamVM.team!.id)
                .offset(x: inputHome.isOpenEditTagSideMenu ? UIScreen.main.bounds.width / 2 - 25 : UIScreen.main.bounds.width + 10)
            }

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

                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 30)
                    .overlay {
                        Text("写真の取得に失敗しました。")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .offset(y: 20)
                    .opacity(inputHome.showErrorFetchImage ? 0.7 : 0.0)
                Spacer()
            }
            .offset(y: 80)

            if inputHome.isShowProgress {
                CustomProgressView()
            }

        } // ZStack
        .ignoresSafeArea()
        .animation(.easeIn(duration: 0.2), value: inputHome.itemsInfomationOpacity)
        .animation(.easeIn(duration: 0.2), value: inputHome.basketInfomationOpacity)
        .animation(.easeIn(duration: 0.2), value: inputHome.showErrorFetchImage)
        .navigationBarBackButtonHidden()

        .sheet(isPresented: $inputHome.isPresentedEditItem) {
            EditItemView(teamVM: teamVM,
                         userVM: userVM,
                         itemVM: itemVM,
                         tagVM: tagVM,
                         inputHome: $inputHome,
                         inputImage: $inputImage,
                         itemIndex: inputHome.actionItemIndex,
                         passItemData: inputHome.editItemStatus == .create ?
                         nil : itemVM.items[inputHome.actionItemIndex],
                         editItemStatus: inputHome.editItemStatus)
        }

        .sheet(isPresented: $inputHome.isShowSelectImageSheet) {
            PHPickerView(captureImage: $inputHome.selectCaptureImage,
                         isShowSheet: $inputHome.isShowSelectImageSheet,
                         isShowError: $inputHome.showErrorFetchImage)
        }

        .onChange(of: inputHome.cartHalfSheet) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                switch inputHome.cartHalfSheet {
                case .hidden: cartAvertOffsetY = 0.0
                case .medium: cartAvertOffsetY = -60.0
                case .large: cartAvertOffsetY = -60.0
                }
            }
        } // .onChange(cartState)
    } // body
} // View

struct NavigationHeader: View {

    @Binding var inputHome: InputHome
    let photoURL: URL?

    var body: some View {

        HStack {
            Button {
                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                    inputHome.isShowSystemSideMenu.toggle()
                }
                withAnimation(.easeIn(duration: 0.2)) {
                    inputHome.sideMenuBackGround.toggle()
                }
            } label: {
                AsyncImageCircleIcon(photoURL: photoURL, size: getSafeArea().top - 10)
            }

            Spacer()

            Button {
                inputHome.editItemStatus = .create
                inputHome.isPresentedEditItem.toggle()
            } label: {
                Image(systemName: "shippingbox.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .offset(x: 7, y: -7)
                    }
            }
        } // HStack
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

        return HomeTabView(logInVM: LogInViewModel(),
                           teamVM: TeamViewModel(),
                           userVM: UserViewModel(),
                           itemVM: ItemViewModel(),
                           tagVM: TagViewModel())
            .environment(\.resizableSheetCenter, resizableSheetCenter)

    }
}
