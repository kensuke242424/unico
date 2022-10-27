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
}

struct LibraryView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var inputHome: InputHome

    @GestureState private var dragOffset: CGFloat = 0
    @State private var inputLibrary: InputLibrary = InputLibrary()

    var body: some View {

        ZStack {
            VStack {
                Image("homePhotoSample")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                    .shadow(radius: 5, x: 0, y: 10)

                // 時刻
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Group {
                            Text("10:07:25")
                                .font(.title3.bold())
                                .frame(height: 40)
                                .scaledToFit()
                                .opacity(0.4)

                            Text("Jun Sun 23")
                                .font(.title3.bold())
                                .opacity(0.6)
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

                // アカウント情報
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
                .blur(radius: 2)
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

                    GeometryReader { bodyView in

                        let libraryItemPadding: CGFloat = 200

                        LazyHStack(spacing: libraryItemPadding) {

                            ForEach(inputLibrary.tagFilterItemCards.indices, id: \.self) {index in

                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.gray)
                                        .frame(width: 180, height: 180)
                                        .overlay {
                                            if inputLibrary.isShowCardInfomation {
                                                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
                                                               startPoint: .top, endPoint: .bottom)
                                            }
                                        }
                                        .overlay(alignment: .bottomTrailing) {
                                            if inputLibrary.isShowCardInfomation {
                                                Text(inputLibrary.tagFilterItemCards[index].name)
                                                    .font(.callout.bold())
                                                    .foregroundColor(.white)
                                                    .opacity(0.7)
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
                                        .onTapGesture(perform: {
                                            inputLibrary.isShowCardInfomation.toggle()
                                        })
                            } // ForEach
                        } // LazyHStack
                        .padding()
                        .offset(x: dragOffset, y: dragOffset)
                        .offset(x: -CGFloat(inputLibrary.currentIndex) * (bodyView.size.width * 0.7 + libraryItemPadding))

                        .gesture(
                            DragGesture()
                                .updating(self.$dragOffset, body: { (value, state, _) in

                                    print(value.translation.width)

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
            print("タグフィルターが更新されました")
        } // .onChange
        .onChange(of: inputLibrary.currentIndex) { new in
            print(new)
        }

        .onAppear {
            if inputLibrary.selectFilterTag == "ALL" {
                inputLibrary.tagFilterItemCards = itemVM.items
            } else {
                inputLibrary.tagFilterItemCards = itemVM.items.filter({ $0.tag == inputLibrary.selectFilterTag })
            }
        } // .onAppear

    } // body
} // View

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(itemVM: ItemViewModel(),
                    inputHome: .constant(InputHome()))
    }
}
