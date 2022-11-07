//
//  ItemLibraryView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct InputLibrary {
    var selectFilterTag: String = "ALL"
    var currentIndex: Int = 0
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

    @StateObject var itemVM: ItemViewModel
    @StateObject var userVM: UserViewModel
    @Binding var inputHome: InputHome

    @GestureState private var dragOffset: CGFloat = 0
    @State private var inputLibrary: InputLibrary = InputLibrary()
    @State private var inputTime: InputTime = InputTime()

    var userImage: UIImage? {
        let convertImage = userVM.convertBase64ToImage(userVM.users[0].photoImage)
        return convertImage
    }

    var body: some View {

        ZStack {

            LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack {

<<<<<<< HEAD
                homeHeaderPhoto(photo: inputHome.selectImage, userIcon: "cloth_sample1")
                    // Todo: ホームレイアウトのカスタム
                    .overlay(alignment: .bottomTrailing) {
                        Menu {
                            Button {
                                // Todo: Homeカスタム
                            } label: {
                                Text("準備中")
                            }
                        } label: {

                            Image(systemName: "gearshape.2")
                                .foregroundColor(.white).opacity(0.5)
                                .padding(.trailing)

                        } // Menu
                        .offset(y: 40)
                    } // overlay
=======
                homeHeaderPhoto(photo: userImage,
                                userIcon: "cloth_sample1")

>>>>>>> 8c313c3 (写真取得時のテキスト)

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
                ForEach(itemVM.tags) { tag in

                    if tag != itemVM.tags.last! {
                        Button {
                            inputLibrary.selectFilterTag = tag.tagName
                        } label: {
                            if inputLibrary.selectFilterTag == tag.tagName {
                                Text("\(tag.tagName)　　 ✔︎")
                            } else {
                                Text(tag.tagName)
                            }
                        }

                    } else {
                        if itemVM.items.contains(where: {$0.tag == (itemVM.tags.last!.tagName)}) {
                            Button {
                                inputLibrary.selectFilterTag = tag.tagName
                            } label: {
                                if inputLibrary.selectFilterTag == tag.tagName {
                                    Text("\(tag.tagName)　　 ✔︎")
                                } else {
                                    Text(tag.tagName)
                                }
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

            homeItemPhotoPanel()
                .ignoresSafeArea()
                .offset(x: -UIScreen.main.bounds.width / 10,
                        y: UIScreen.main.bounds.height / 4)

        } // ZStack
        .onChange(of: inputLibrary.selectFilterTag) { newValue in
            if newValue == "ALL" {
                inputLibrary.tagFilterItemCards = itemVM.items
                inputLibrary.currentIndex =  0
                return
            }
            inputLibrary.tagFilterItemCards = itemVM.items.filter({ $0.tag == newValue })
            inputLibrary.currentIndex =  0
        } // .onChange

        .onAppear {

            if inputLibrary.selectFilterTag == "ALL" {
                inputLibrary.tagFilterItemCards = itemVM.items
            } else {
                inputLibrary.tagFilterItemCards = itemVM.items.filter({ $0.tag == inputLibrary.selectFilterTag })
            }
        } // .onAppear
    } // body

    @ViewBuilder
    func homeHeaderPhoto(photo: UIImage?, userIcon: String) -> some View {

        if let photo = photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .frame(width: getRect().width, height: getRect().height * 0.35)
                .clipped()
                .shadow(radius: 5, x: 0, y: 10)
                .overlay {
                    if inputLibrary.isShowHeaderPhotoInfomation {
                        LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.2)]),
                                       startPoint: .top, endPoint: .bottom)
                    }
                } // overlay
                .overlay(alignment: .topLeading) {
                    if inputLibrary.isShowHeaderPhotoInfomation {
                        Button {
                            inputLibrary.isShowHeaderPhotoInfomation.toggle()
                        } label: {
                            CircleIcon(photo: userIcon, size: 35)
                                .offset(y: getSafeArea().top)
                        }
                    }
                } // overlay
                .overlay(alignment: .bottomTrailing) {
                    if inputLibrary.isShowHeaderPhotoInfomation {
                        Button {
                            // Todo: 画像変更処理
                            inputHome.isShowSelectImageSheet.toggle()
                        } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                } // overlay
                .animation(.easeIn(duration: 0.2), value: inputLibrary.isShowHeaderPhotoInfomation)
                .onTapGesture { inputLibrary.isShowHeaderPhotoInfomation.toggle() }
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
                .offset(y: 40)
            } // overlay
        } else {
            VStack {
                Text("写真の取得ができませんでした")
                    .foregroundColor(.white.opacity(0.3))

                Button {
                    // Todo: 画像変更処理
                    inputHome.isShowSelectImageSheet.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 30)
                }
            }
            .frame(width: getRect().width, height: getRect().height * 0.35)

        } // if let photo

    } // homeHeaderPhoto

    func homeItemPhotoPanel() -> some View {
        GeometryReader { bodyView in

            let libraryItemPadding: CGFloat = 200
            let panelSize = UIScreen.main.bounds.height / 4

            LazyHStack(spacing: libraryItemPadding) {

                ForEach(inputLibrary.tagFilterItemCards.indices, id: \.self) {index in

                    ShowItemPhoto(photo: inputLibrary.tagFilterItemCards[index].photo, size: panelSize)
                            .overlay {
                                if inputLibrary.isShowCardInfomation {
                                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                                                   startPoint: .top, endPoint: .bottom)
                                }
                            }
                            .overlay(alignment: .bottomTrailing) {
                                if inputLibrary.isShowCardInfomation {
                                    Text(inputLibrary.tagFilterItemCards[index].name)
                                        .font(.footnote).foregroundColor(.white).opacity(0.7)
                                        .tracking(2)
                                        .lineLimit(1)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if inputLibrary.isShowCardInfomation {
                                    Button {
                                        if let cardRowIndex =
                                            itemVM.items.firstIndex(where: { $0.id == inputLibrary.tagFilterItemCards[index].id }) {

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
            .offset(x: -CGFloat(inputLibrary.currentIndex) * (bodyView.size.width * 0.7 + libraryItemPadding))

            .gesture(
                DragGesture()
                    .updating(self.$dragOffset, body: { (value, state, _) in

                        // 先頭・末尾ではスクロールする必要がないので、画面幅の1/5までドラッグで制御する
                        if inputLibrary.currentIndex == 0, value.translation.width > 0 {
                            state = value.translation.width / 5
                        } else if inputLibrary.currentIndex == (inputLibrary.tagFilterItemCards.count - 1), value.translation.width < 0 {
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

                        var newIndex = inputLibrary.currentIndex
                        inputLibrary.cardOpacity = 1.0

                        // ドラッグ幅からページングを判定
                        if abs(value.translation.width) > bodyView.size.width * 0.2 {
                            newIndex = value.translation.width > 0 ? inputLibrary.currentIndex - 1 : inputLibrary.currentIndex + 1
                        }
                        if newIndex < 0 {
                            newIndex = 0
                        } else if newIndex > (inputLibrary.tagFilterItemCards.count - 1) {
                            newIndex = inputLibrary.tagFilterItemCards.count - 1
                        }
                        inputLibrary.currentIndex = newIndex

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
                    userVM: UserViewModel(),
                    inputHome: .constant(InputHome()))
    }
}
