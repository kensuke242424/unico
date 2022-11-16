//
//  ItemLibraryView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct InputLibrary {
    var selectFilterTag: String = "ALL"
    var homeCardsIndex: Int = 0
    var libraryCardIndex: Int = 0
    var cardOpacity: CGFloat =  1.0
    var tagFilterItemCards: [Item] = []
    var isShowCardInfomation: Bool = false
    var isShowHeaderPhotoInfomation: Bool = false
}

struct InputTime {

    var nowDate =  Date()
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var time: String {
        let formatter = DateFormatter()
        formatter.setTemplate(.time, .enUS)
        return formatter.string(from: nowDate)
    }
    var week: String {
        let formatter = DateFormatter()
        formatter.setTemplate(.usWeek, .enUS)
        return formatter.string(from: nowDate)
    }
    var dateStyle: String {
        let formatter = DateFormatter()
        formatter.setTemplate(.usMonthDay, .enUS)
        return formatter.string(from: nowDate)
    }
}

struct LibraryView: View {

    enum HeaderImageSize {
        case fit, fill
    }

    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel
    @Binding var inputHome: InputHome
    @Binding var inputImage: InputImage

    @GestureState private var dragOffset: CGFloat = 0
    @State private var inputLibrary: InputLibrary = InputLibrary()
    @State private var inputTime: InputTime = InputTime()
    @State private var headerImageSize: HeaderImageSize = .fit

    var tagFilterItemCards: [Item] {

        if inputLibrary.selectFilterTag == tagVM.tags.first!.tagName {
            return itemVM.items
        } else {
            return itemVM .items.filter({ $0.tag == inputLibrary.selectFilterTag })
        }
    }

    var body: some View {

        ZStack {

            LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack {

                homeHeaderPhoto(photo: inputImage.headerImage, userIcon: "cloth_sample1")
                // 時刻レイアウト
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Group {
                            Text(inputTime.time)
                                .tracking(8)
                                .font(.title3.bold())
                                .frame(height: 40)
                                .opacity(0.4)

                            Text("\(inputTime.week).")
                                .font(.subheadline)
                                .opacity(0.4)

                            Text(inputTime.dateStyle)
                                .font(.subheadline.bold())
                                .opacity(0.5)
                                .padding(.leading)
                        }
                        .italic()
                        .tracking(5)
                        .foregroundColor(.white)
                    } // VStack
                    Spacer()
                } // HStack
                .padding(.top, 30)
                .padding(.leading, 20)
                .shadow(radius: 4, x: 3, y: 3)
                .onReceive(inputTime.timer) { _ in
                    inputTime.nowDate = Date()
                }

                // ユーザ情報一覧
                HStack {
                    Spacer()

                    ZStack {
                        VStack(alignment: .leading, spacing: 60) {

                            Group {
                                Text("Useday.  ")
                                Text("Items.  ")
                                Text("Member.  ")
                            }
                            .font(.footnote)
                            .foregroundColor(.white)
                            .tracking(5)
                            .opacity(0.3)

                        } // VStack

                        VStack(alignment: .trailing, spacing: 60) {
                            Group {
                                Text("55 day")
                                Text("\(itemVM.items.count) item")
                            }
                            .font(.footnote)
                            HStack {
                                ForEach(0...2, id: \.self) { _ in
                                    Image(systemName: "person.crop.circle.fill")
                                }
                            }
                        }
                        .offset(x: 20, y: 35)
                        .tracking(5)
                        .foregroundColor(.white)
                        .opacity(0.5)
                    } // ZStack
                } // HStack
                .offset(y: -30)
                .padding(.horizontal)

                Spacer()

            } // VStack
            .ignoresSafeArea()

            CustomArcShape()
                .ignoresSafeArea()
                .foregroundColor(.white)
                .blur(radius: 1)
                .opacity(0.08)

            Menu {
                ForEach(tagVM.tags) { tag in

                    if tag != tagVM.tags.last! {
                        Button {
                            inputLibrary.selectFilterTag = tag.tagName
                        } label: {
                            Text(inputLibrary.selectFilterTag == tag.tagName ? "\(tag.tagName)　　 ✔︎" : tag.tagName)
                        }

                    } else {
                        if itemVM.items.contains(where: {$0.tag == (tagVM.tags.last!.tagName)}) {
                            Button {
                                inputLibrary.selectFilterTag = tag.tagName
                            } label: {
                                Text(inputLibrary.selectFilterTag == tag.tagName ? "\(tag.tagName)　　 ✔︎" : tag.tagName)
                            }
                        }
                    }

                } // ForEach
            } label: {
                Image(systemName: "list.bullet")
                    .font(.title3)
                    .foregroundColor(.white)
            } // Menu
            .ignoresSafeArea()
            .offset(x: -UIScreen.main.bounds.width / 2.5,
                    y: UIScreen.main.bounds.height / 11)

            if itemVM.items == [] {
                EmptyItemView(inputHome: $inputHome, text: "")
                    .offset(x: -UIScreen.main.bounds.width / 4,
                            y: UIScreen.main.bounds.height / 5)
            } else if tagFilterItemCards == [] {
                VStack(spacing: 10) {
                    Text(inputLibrary.selectFilterTag)
                    Text("該当アイテムなし")
                }
                .foregroundColor(.white.opacity(0.7))
                .offset(x: -UIScreen.main.bounds.width / 4,
                        y: UIScreen.main.bounds.height / 5)
            } else {
                homeItemPhotoPanel(items: tagFilterItemCards)
                    .ignoresSafeArea()
                    .offset(x: -UIScreen.main.bounds.width / 10,
                            y: UIScreen.main.bounds.height / 4)
            }
        } // ZStack

        .onChange(of: inputLibrary.selectFilterTag) { _ in
            inputLibrary.homeCardsIndex =  0
        } // .onChange

    } // body

    @ViewBuilder
    func homeHeaderPhoto(photo: UIImage?, userIcon: String) -> some View {

        Group {
            if let photo = photo {
                ZStack {

                    Rectangle().opacity(0.0001)
                        .frame(width: getRect().width, height: getRect().height * 0.35)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.2)) {
                                inputLibrary.isShowHeaderPhotoInfomation.toggle()
                            }
                        }
                    Group {
                        switch headerImageSize {
                        case .fit:
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                        case .fill:
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: getRect().width, height: getRect().height * 0.35)
                    .clipped()
                    .allowsHitTesting(false)
                    .shadow(radius: 5, x: 0, y: 10)
                }

            } else {
                VStack {
                    Text("写真を選択しましょう")
                        .foregroundColor(.white.opacity(0.3))
                        .offset(y: 20)

                    Button {
                        // Todo: 画像変更処理
                        inputHome.updateImageStatus = .header
                        inputHome.isShowSelectImageSheet.toggle()
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 30)
                    }
                    .offset(y: 20)
                }
                .frame(width: getRect().width, height: getRect().height * 0.35)
            } // if let photo
        } // Group
        .overlay {

            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.2)]),
                           startPoint: .top, endPoint: .bottom)
            .shadow(radius: 5, x: 0, y: 10)
            .opacity(inputLibrary.isShowHeaderPhotoInfomation ? 0.4 : 0.0)
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    inputLibrary.isShowHeaderPhotoInfomation.toggle()
                }
            }

        } // overlay

        .overlay(alignment: .bottomTrailing) {

            Menu {
                Menu("サイズ調整") {
                    Button {
                        withAnimation(.spring()) { headerImageSize = .fit }
                    } label: {
                        Label(headerImageSize == .fit ? "Fit  　　     ✔︎" : "Fit", systemImage: "crop")
                    }
                    Button {
                        withAnimation(.spring()) { headerImageSize = .fill }
                    } label: {
                        Label(headerImageSize == .fill ? "Full        ✔︎" : "Full", systemImage: "rectangle.dashed")
                    }
                }

                Button {
                    inputHome.updateImageStatus = .header
                    inputHome.isShowSelectImageSheet.toggle()
                } label: {
                    Label("写真を選択", systemImage: "photo")
                }

            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            } // Menu
            .padding()
            .opacity(inputLibrary.isShowHeaderPhotoInfomation ? 1.0 : 0.0)
        } // overlay

        .overlay(alignment: .topLeading) {
            Button {
                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                    inputHome.isShowSystemSideMenu.toggle()
                }
                withAnimation(.easeIn(duration: 0.2)) {
                    inputHome.sideMenuBackGround.toggle()
                }
            } label: {
                CircleIcon(photo: inputImage.iconImage, size: getSafeArea().top - 20)
            }
            .padding(.leading)
            .offset(y: getSafeArea().top)
            .opacity(inputLibrary.isShowHeaderPhotoInfomation || photo == nil ? 1.0 : 0.0)
        } // overlay

        // Todo: ホームレイアウトのカスタム
        .overlay(alignment: .bottomTrailing) {
            Menu {
                Button {

                } label: {
                    Text("準備中")
                }
            } label: {

                Image(systemName: "gearshape.2")
                    .foregroundColor(.white).opacity(0.5)
                    .padding(.trailing)

            } // Menu
            .offset(y: 50)
        } // overlay
        .ignoresSafeArea()
    } // homeHeaderPhoto

    func homeItemPhotoPanel(items: [Item]) -> some View {
        GeometryReader { bodyView in

            let libraryItemPadding: CGFloat = 200
            let panelSize = UIScreen.main.bounds.height / 4

            LazyHStack(spacing: libraryItemPadding) {

                ForEach(tagFilterItemCards.indices, id: \.self) {index in

                    ShowItemPhoto(photo: tagFilterItemCards[index].photo, size: panelSize)

                        .overlay {
                            if inputLibrary.isShowCardInfomation {
                                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                                               startPoint: .top, endPoint: .bottom)
                            }
                        }
                        .overlay(alignment: .bottomTrailing) {
                            if inputLibrary.isShowCardInfomation {
                                Text(tagFilterItemCards[index].name)
                                    .font(.footnote).foregroundColor(.white).opacity(0.7)
                                    .tracking(2)
                                    .lineLimit(1)
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            if inputLibrary.isShowCardInfomation {
                                Button {
                                    if let cardRowIndex =
                                        itemVM.items.firstIndex(where: { $0.id == tagFilterItemCards[index].id }) {

                                        inputHome.actionItemIndex = cardRowIndex

                                        withAnimation(.easeIn(duration: 0.15)) {
                                            inputHome.isShowItemDetail.toggle()
                                        }
                                    } else {
                                        print("LibraryCardIndexの取得エラー")
                                    }
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .resizable().scaledToFit().frame(width: 20)
                                        .foregroundColor(.white)
                                } // Button
                            } // if
                        } // overlay
                        .opacity(inputLibrary.cardOpacity)
                        .shadow(radius: 4, x: 5, y: 5)
                        .frame(width: bodyView.size.width * 0.7, height: 40)
                        .animation(.easeIn(duration: 0.2), value: inputLibrary.isShowCardInfomation)
                        .onTapGesture { inputLibrary.isShowCardInfomation.toggle() }
                } // ForEach
            } // LazyHStack
            .padding()
            .offset(x: dragOffset, y: dragOffset)
            .offset(x: -CGFloat(inputLibrary.homeCardsIndex) * (bodyView.size.width * 0.7 + libraryItemPadding))

            .gesture(
                DragGesture()
                    .updating(self.$dragOffset, body: { (value, state, _) in

                        // 先頭・末尾ではスクロールする必要がないので、画面幅の1/5までドラッグで制御する
                        if inputLibrary.homeCardsIndex == 0, value.translation.width > 0 {
                            state = value.translation.width / 5
                        } else if inputLibrary.homeCardsIndex == (tagFilterItemCards.count - 1), value.translation.width < 0 {
                            state = value.translation.width / 5
                        } else {
                            state = value.translation.width
                        }

                        if value.translation.width > 0 {
                            inputLibrary.cardOpacity = 1.0 - value.translation.width / 100
                        } else if value.translation.width < 0 {
                            inputLibrary.cardOpacity = 1.0 + value.translation.width / 100
                        }
                    })
                    .onEnded({ value in

                        var newIndex = inputLibrary.homeCardsIndex
                        inputLibrary.cardOpacity = 1.0

                        // ドラッグ幅からページングを判定
                        if abs(value.translation.width) > bodyView.size.width * 0.2 {
                            newIndex = value.translation.width > 0 ? inputLibrary.homeCardsIndex - 1 : inputLibrary.homeCardsIndex + 1
                        }
                        if newIndex < 0 {
                            newIndex = 0
                        } else if newIndex > (tagFilterItemCards.count - 1) {
                            newIndex = tagFilterItemCards.count - 1
                        }
                        inputLibrary.homeCardsIndex = newIndex

                    }) // .onEnded
            ) // .gesture
            // 減衰ばねモデル、それぞれの値は操作感に応じて変更する
            .animation(.interpolatingSpring(mass: 0.8,
                                            stiffness: 100,
                                            damping: 80,
                                            initialVelocity: 0.1),
                       value: dragOffset)
        } // Geometry
    } // homeItemPhotoPanel

} // View

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(itemVM: ItemViewModel(),
                    tagVM: TagViewModel(),
                    inputHome: .constant(InputHome()),
                    inputImage: .constant(InputImage()))
    }
}
