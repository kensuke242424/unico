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
    let timeFormatter = DateFormatter()
    let weekFormatter = DateFormatter()
    let dateStyleFormatter = DateFormatter()
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
}

struct LibraryView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var inputHome: InputHome

    @GestureState private var dragOffset: CGFloat = 0
    @State private var inputLibrary: InputLibrary = InputLibrary()
    @State private var inputTime: InputTime = InputTime()

    var body: some View {

        ZStack {
            VStack {

                homeHeaderPhoto(photo: "homePhoto_sample", userIcon: "cloth_sample1")

                // 時刻レイアウト
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Group {
                            Text(inputTime.timeFormatter.string(from: inputTime.nowDate))
                                .tracking(8)
                                .font(.title3.bold())
                                .frame(height: 40)
                                .opacity(0.4)

                            Text(inputTime.weekFormatter.string(from: inputTime.nowDate))
                                .font(.subheadline)
                                .opacity(0.4)

                            Text(inputTime.dateStyleFormatter.string(from: inputTime.nowDate))
                                .font(.headline.bold())
                                .opacity(0.5)
                                .padding(.leading)
                        }
                        .italic()
                        .tracking(5)
                        .foregroundColor(.white)
                    } // VStack
                    Spacer()
                } // HStack
                .padding(.top, 20)
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
            .background(
                LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                               startPoint: .top, endPoint: .bottom)
            )
            CustomArcShape()
                .ignoresSafeArea()
                .foregroundColor(.white)
                .blur(radius: 1)
                .opacity(0.08)

            Menu {
                ForEach(itemVM.tags) { tag in
                    Button {
                        inputLibrary.selectFilterTag = tag.tagName
                    } label: {
                        if inputLibrary.selectFilterTag == tag.tagName {
                            Text("\(tag.tagName)　　 ✔︎")
                        } else {
                            Text(tag.tagName)
                        }
                    }
                } // ForEach
            } label: {
                Image(systemName: "list.bullet")
                    .foregroundColor(.white)
            } // Menu
            .offset(x: -UIScreen.main.bounds.width / 2.5,
                    y: UIScreen.main.bounds.height / 10)

            homeItemPhotoPanel()
                    .offset(x: -UIScreen.main.bounds.width / 10,
                            y: UIScreen.main.bounds.height / 4)

            if inputHome.isShowItemDetail {
                ShowsItemDetail(itemVM: itemVM,
                                item: itemVM.items[inputLibrary.libraryCardIndex],
                                itemIndex: inputLibrary.libraryCardIndex,
                                isShowItemDetail: $inputHome.isShowItemDetail,
                                isPresentedEditItem: $inputHome.isPresentedEditItem)
            } // if isShowItemDetail

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
            inputTime.timeFormatter.setTemplate(.time) // 時間
            inputTime.weekFormatter.setTemplate(.usWeek) // 週
            inputTime.dateStyleFormatter.dateStyle = .medium // Nov 1, 2022

            if inputLibrary.selectFilterTag == "ALL" {
                inputLibrary.tagFilterItemCards = itemVM.items
            } else {
                inputLibrary.tagFilterItemCards = itemVM.items.filter({ $0.tag == inputLibrary.selectFilterTag })
            }
        } // .onAppear

    } // body

    @ViewBuilder
    func homeHeaderPhoto(photo: String, userIcon: String) -> some View {

        Image(photo)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .frame(height: UIScreen.main.bounds.height * 0.3)
            .shadow(radius: 5, x: 0, y: 10)
            .overlay {
                if inputLibrary.isShowHeaderPhotoInfomation {
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                   startPoint: .top, endPoint: .bottom)
                }
            } // overlay
            .overlay(alignment: .topLeading) {
                if inputLibrary.isShowHeaderPhotoInfomation {
                    Button {
                        inputLibrary.isShowHeaderPhotoInfomation.toggle()
                    } label: {
                        CircleIcon(photo: userIcon, size: 35)
                    }
                }
            } // overlay
            .overlay(alignment: .bottomTrailing) {
                if inputLibrary.isShowHeaderPhotoInfomation {
                    Button {
                        // Todo: 画像変更処理
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            } // overlay
            .animation(.easeIn(duration: 0.2), value: inputLibrary.isShowHeaderPhotoInfomation)
            .onTapGesture { inputLibrary.isShowHeaderPhotoInfomation.toggle() }
    } // homeHeaderPhoto
    func homeItemPhotoPanel() -> some View {
        GeometryReader { bodyView in

            let libraryItemPadding: CGFloat = 200

            LazyHStack(spacing: libraryItemPadding) {

                ForEach(inputLibrary.tagFilterItemCards.indices, id: \.self) {index in

                    ShowItemPhoto(photo: inputLibrary.tagFilterItemCards[index].photo, size: 180)
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
                                            itemVM.items.firstIndex(of: inputLibrary.tagFilterItemCards[index]) {
                                            inputLibrary.libraryCardIndex = cardRowIndex
                                            inputHome.isShowItemDetail.toggle()
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
                    inputHome: .constant(InputHome()))
    }
}
