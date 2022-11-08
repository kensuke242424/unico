//
//  SalesItemDetailView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/30.
//

import SwiftUI

struct ShowsItemDetail: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var inputHome: InputHome
    let item: Item

    struct InputItemDetail {
        var opacity: Double = 0
        var isShowAlert: Bool = false
        var isPresentedEditItem: Bool = false
    }

    private let screenSize: CGRect = UIScreen.main.bounds
    @State private var inputDetail: InputItemDetail = InputItemDetail()

    var body: some View {

        ZStack {

            Color(.black).opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    inputHome.isShowItemDetail.toggle()
                }

            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
                .frame(width: screenSize.width * 0.75, height: screenSize.height * 0.55)
                .opacity(0.9)
                .overlay {
                    Color.customDarkBlue2.opacity(0.5)
                        .blur(radius: 20)
                        .overlay(alignment: .bottom) {

                            Button {
                                inputHome.isShowItemDetail.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "multiply.circle.fill")
                                    Text("閉じる")
                                }
                                .font(.title3).foregroundColor(.white)
                                .offset(y: 50)
                            }

                        }
                }

                .overlay {
                    VStack {
                        Text(item.name).fontWeight(.bold).foregroundColor(.white)
                            .tracking(1)
                            .lineLimit(1)

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 10) {

                                ShowItemPhoto(photo: item.photo, size: screenSize.width * 0.35)
                                    .padding()

                                HStack {
                                    Text("　アイテム情報")
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)

                                    Button {
                                        inputDetail.isShowAlert.toggle()

                                    } label: {
                                        Image(systemName: "highlighter")
                                            .foregroundColor(.yellow)
                                    }
                                    .alert("編集", isPresented: $inputDetail.isShowAlert) {

                                        Button {
                                            inputDetail.isShowAlert.toggle()
                                        } label: {
                                            Text("戻る")
                                        }

                                        Button {
                                            inputHome.editItemStatus = .update
                                            inputHome.isPresentedEditItem.toggle()
                                        } label: {
                                            Text("はい")
                                        }
                                    } message: {
                                        Text("アイテムデータを編集しますか？")
                                    } // alert

                                } // HStack

                                Divider().background(.white).opacity(0.5)
                                    .padding()

                                // NOTE: アイテムの情報が格納羅列されたカスタムViewです
                                ItemDetailData(item: item)

                                Divider().background(.white).opacity(0.5)
                                    .padding()

                                HStack {
                                    Text("Memo.")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.leading, 20)

                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray).opacity(0.2)
                                    .frame(width: screenSize.width * 0.6, height: 300)
                                    .overlay(alignment: .topLeading) {
                                        ScrollView {
                                            Text(item.detail).font(.caption).foregroundColor(.white)
                                                .padding(10)
                                        }
                                    }
                            } // VStack
                        } // ScrollView
                    } // VStack
                    .padding(.vertical, 30)
                }// overlay
                .offset(y: -30)
        } // ZStack(全体)
        .opacity(inputDetail.opacity)

        .onAppear {
            withAnimation(.linear(duration: 0.2)) {
                inputDetail.opacity = 1.0
            }
        } // .onAppear

    } // body
} // View

struct ShowsItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        ShowsItemDetail(itemVM: ItemViewModel(),
                        inputHome: .constant(InputHome()),
                        item: TestItem().testItem)
    }
}
