//
//  HomeView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI
import ResizableSheet

// NOTE: アイテムの「追加」「更新」を管理します
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
    var selectCaptureImage: UIImage? = UIImage()
    var itemsInfomationOpacity: CGFloat = 0.0
    var basketInfomationOpacity: CGFloat = 0.0
    var showErrorFetchImage: Bool = false
    var isShowItemDetail: Bool = false
    var isPresentedEditItem: Bool = false
    var isOpenEditTagSideMenu: Bool = false
    var isShowSearchField: Bool = false
    var isShowSystemSideMenu: Bool = false
    var editTagSideMenuBackground: Bool = false
    var sideMenuBackGround: Bool = false
    var isShowSelectImageSheet: Bool = false
    var doCommerce: Bool = false
    var doItemEdit: Bool = false
    var editItemStatus: EditStatus = .create
    var updateImageStatus: UpdateImageStatus = .item
    var cartHalfSheet: ResizableSheetState = .hidden
    var commerceHalfSheet: ResizableSheetState = .hidden
}

struct InputImage {
    var headerImage: UIImage? = nil
    var iconImage: UIImage? = nil
    var itemImage: UIImage? = nil
}

struct HomeTabView: View {

    @StateObject var userVM: UserViewModel = UserViewModel()
    @StateObject var rootItemVM: ItemViewModel = ItemViewModel()
    @StateObject var tagVM: TagViewModel = TagViewModel()
    @State private var inputHome: InputHome = InputHome()
    @State private var inputImage: InputImage = InputImage()
    @State private var inputSideMenu: InputSideMenu = InputSideMenu()
    @State private var inputTag: InputTagSideMenu = InputTagSideMenu()
    @State private var cartAvertOffsetY: CGFloat = 0.0

    let userID: String

    var body: some View {

        ZStack {

            TabView(selection: $inputHome.homeTabIndex) {

                LibraryView(itemVM: rootItemVM,
                            tagVM: tagVM,
                            inputHome: $inputHome,
                            inputImage: $inputImage)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                StockView(itemVM: rootItemVM,
                          tagVM: tagVM,
                          inputHome: $inputHome,
                          inputImage: $inputImage,
                          userID: userID)
                    .tabItem {
                        Image(systemName: "shippingbox.fill")
                        Text("inventory")
                    }
                    .tag(1)

                ManageView(itemVM: rootItemVM,
                           tagVM: tagVM,
                           inputHome: $inputHome,
                           inputImage: $inputImage)
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Manage")
                    }
                    .tag(2)

            } // TabViewここまで

            UsefulButton(inputHome: $inputHome)
                .offset(x: UIScreen.main.bounds.width / 3 - 5,
                        y: UIScreen.main.bounds.height / 3 - 10)
                .offset(y: cartAvertOffsetY)

            ElementSwitchingPickerView(switchElement: $inputHome.switchElement, tabIndex: $inputHome.homeTabIndex)
                .offset(y: getRect().height / 2 - getSafeArea().bottom - 110)
                .offset(y: cartAvertOffsetY)

            if rootItemVM.items.count != 0 {
                ShowsItemDetail(itemVM: rootItemVM,
                                inputHome: $inputHome,
                                item: rootItemVM.items[inputHome.actionItemIndex])
                .opacity(inputHome.isShowItemDetail ? 1.0 : 0.0)
            }

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

            SystemSideMenu(itemVM: rootItemVM,
                           tagVM: tagVM,
                           inputHome: $inputHome,
                           inputImage: $inputImage,
                           inputTag: $inputTag,
                           inputSideMenu: $inputSideMenu)
                .offset(x: inputHome.isShowSystemSideMenu ? 0 : -UIScreen.main.bounds.width)

            // sideMenu_background...
            Color.black
                .ignoresSafeArea()
                .opacity(inputHome.editTagSideMenuBackground ? 0.4 : 0)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, blendDuration: 1)) {
                        inputHome.editTagSideMenuBackground.toggle()
                    }
                    withAnimation(.easeIn(duration: 0.2)) {
                        inputHome.isOpenEditTagSideMenu.toggle()
                    }
                }

            // Open TagSideMenu...
            SideMenuEditTagView(itemVM: rootItemVM,
                                tagVM: tagVM,
                                inputHome: $inputHome,
                                inputTag: $inputTag,
                                defaultTag: inputTag.tagSideMenuStatus == .create ? nil : inputSideMenu.selectTag,
                                tagSideMenuStatus: inputTag.tagSideMenuStatus)
            .offset(x: inputHome.isOpenEditTagSideMenu ? UIScreen.main.bounds.width / 2 - 25 : UIScreen.main.bounds.width + 10)

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

        } // ZStack
        .animation(.easeIn(duration: 0.2), value: inputHome.itemsInfomationOpacity)
        .animation(.easeIn(duration: 0.2), value: inputHome.basketInfomationOpacity)
        .animation(.easeIn(duration: 0.2), value: inputHome.showErrorFetchImage)
        .navigationBarBackButtonHidden()

        .sheet(isPresented: $inputHome.isPresentedEditItem) {
            EditItemView(itemVM: rootItemVM,
                         tagVM: tagVM,
                         inputHome: $inputHome,
                         inputImage: $inputImage,
                         userID: userID,
                         itemIndex: inputHome.actionItemIndex,
                         passItemData: inputHome.editItemStatus == .create ?
                         nil : rootItemVM.items[inputHome.actionItemIndex],
                         editItemStatus: inputHome.editItemStatus)
        }

        .sheet(isPresented: $inputHome.isShowSelectImageSheet) {
            PHPickerView(captureImage: $inputHome.selectCaptureImage,
                         isShowSheet: $inputHome.isShowSelectImageSheet,
                         isShowError: $inputHome.showErrorFetchImage)
        }

        // convert UIImage ⇨ base64String...
        .onChange(of: inputHome.selectCaptureImage) { newImage in

            guard let base64StringImage = newImage?.toBase64String() else {
                inputHome.showErrorFetchImage.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    inputHome.showErrorFetchImage.toggle()
                }
                return
            }

            switch inputHome.updateImageStatus {
            case .item:
                print("別のブランチでInputHomeにactionItemIndexが格納されているため、マージ後そちらを使用して更新")
            case .icon:
                guard userVM.users.first != nil else { return }
                userVM.users[0].iconImage = base64StringImage
                inputImage.iconImage = userVM.users.first!.iconImage.toImage()

            case .header:
                guard userVM.users.first != nil else { return }

            }
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

        .onAppear {
            Task {
                await tagVM.fetchTag(groupID: tagVM.groupID)
                print("fetchTagメソッド終わり")
                await rootItemVM.fetchItem()
                print("fetchItemメソッド終わり")

            }
        }

    } // body
} // View

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

        return HomeTabView(userID: "AAAAAAAAAAAA")
            .environment(\.resizableSheetCenter, resizableSheetCenter)

    }
}
