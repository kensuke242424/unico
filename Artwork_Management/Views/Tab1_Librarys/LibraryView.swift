//
//  ItemLibraryView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct InputLibrary {
    var currentIndex: Int = 0
}

struct LibraryView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var isShowItemDetail: Bool

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
                    .shadow(radius: 5, x: 0, y: 1)
                    .shadow(radius: 5, x: 0, y: 1)
                    .shadow(radius: 5, x: 0, y: 1)
                    .shadow(radius: 5, x: 0, y: 1)

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
                            .opacity(0.4)

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
                .opacity(0.08)

                    GeometryReader { bodyView in

                        let libraryItemPadding: CGFloat = 150

                        LazyHStack(spacing: libraryItemPadding) {

                            ForEach(itemVM.items.indices, id: \.self) {index in

                                Text(itemVM.items[index].name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .bold))
                                    .frame(width: bodyView.size.width * 0.7, height: 40)
                                    .padding(.leading, index == 0 ? bodyView.size.width * 0 : 0)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.gray)
                                            .opacity(0.5)
                                            .frame(width: 200, height: 200)
                                    }

                            } // ForEach
                        } // LazyHStack
                        .padding()
                        .offset(x: self.dragOffset)
                        .offset(x: -CGFloat(inputLibrary.currentIndex) * (bodyView.size.width * 0.7 + libraryItemPadding))

                        .gesture(
                            DragGesture()
                                .updating(self.$dragOffset, body: { (value, state, _) in

                                    // 先頭・末尾ではスクロールする必要がないので、画面幅の1/5までドラッグで制御する
                                    if inputLibrary.currentIndex == 0, value.translation.width > 0 {
                                        state = value.translation.width / 5
                                    } else if inputLibrary.currentIndex == (itemVM.items.count - 1), value.translation.width < 0 {
                                        state = value.translation.width / 5
                                    } else {
                                        state = value.translation.width
                                    }
                                })
                                .onEnded({ value in
                                    var newIndex = inputLibrary.currentIndex

                                    // ドラッグ幅からページングを判定
                                    // 今回は画面幅x0.3としているが、操作感に応じてカスタマイズする必要がある
                                    if abs(value.translation.width) > bodyView.size.width * 0.1 {
                                        newIndex = value.translation.width > 0 ? inputLibrary.currentIndex - 1 : inputLibrary.currentIndex + 1
                                    }
                                    if newIndex < 0 {
                                        newIndex = 0
                                    } else if newIndex > (itemVM.items.count - 1) {
                                        newIndex = itemVM.items.count - 1
                                    }
                                    inputLibrary.currentIndex = newIndex

                                }) // .onEnded
                        ) // .gesture
                        // 減衰ばねモデル、それぞれの値は操作感に応じて変更する
                        .animation(.interpolatingSpring(mass: 0.4,
                                                        stiffness: 100,
                                                        damping: 80,
                                                        initialVelocity: 0.1),
                                   value: dragOffset)
                    } // Geometry
                    .offset(x: -UIScreen.main.bounds.width / 10,
                            y: UIScreen.main.bounds.height / 4)

        } // ZStack
    } // body
} // View

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(itemVM: ItemViewModel(),
                    isShowItemDetail: .constant(false))
    }
}
