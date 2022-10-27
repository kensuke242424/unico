//
//  ItemLibraryView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct LibraryView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var isShowItemDetail: Bool

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
                .padding(.horizontal)

                Spacer()

            } // VStack
            .background(

                LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                               startPoint: .top, endPoint: .bottom)
            )
        } // ZStack
    } // body
} // View

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(itemVM: ItemViewModel(),
                    isShowItemDetail: .constant(false))
    }
}
