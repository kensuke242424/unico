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

    @State private var inputDetail: InputItemDetail = InputItemDetail()

    var body: some View {

        ZStack {

            Color(.black)
                .ignoresSafeArea()
                .opacity(0.4)
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.15)) {
                        inputHome.isShowItemDetail.toggle()
                    }
                }

            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
                .frame(width: 300, height: 470)
                .opacity(0.9)
                .overlay {
                    Color.customDarkBlue2
                        .opacity(0.5)
                        .blur(radius: 20)
                        .overlay(alignment: .topLeading) {
                            Button {
                                withAnimation(.easeIn(duration: 0.15)) {
                                    inputHome.isShowItemDetail.toggle()
                                }
                            } label: {
                                Image(systemName: "multiply.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                            }

                        }
                }

                .overlay {
                    VStack {
                        Text(item.name)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .tracking(1)
                            .lineLimit(1)

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 10) {

                                ShowItemPhoto(photo: item.photo, size: 150)

                                HStack {
                                    Text("　アイテム情報")
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)

                                    Button {
                                        // NOTE: アイテム編集画面へ遷移するかをアラートで選択
                                        inputDetail.isShowAlert.toggle()

                                    } label: {
                                        Image(systemName: "highlighter")
                                            .foregroundColor(.yellow)
                                    }
                                    .alert("編集", isPresented: $inputDetail.isShowAlert) {

                                        Button {
                                            inputDetail.isShowAlert.toggle()
                                            print("isShowAlert: \(inputDetail.isShowAlert)")
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

                                Divider()
                                    .background(.white)
                                    .opacity(0.5)
                                    .padding()

                                // NOTE: アイテムの情報が格納羅列されたカスタムViewです
                                ItemDetailData(item: item)

                                Divider()
                                    .background(.white)
                                    .opacity(0.5)
                                    .padding()

                                HStack {
                                    Text("Memo.")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.leading, 20)

                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray)
                                    .frame(width: 250, height: 300)
                                    .opacity(0.2)
                                    .overlay(alignment: .topLeading) {
                                        ScrollView {
                                            Text(item.detail)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(10)
                                        }
                                    }
                            } // VStack
                        } // ScrollView
                    } // VStack
                    .padding(.vertical, 30)
                }// overlay
        } // ZStack(全体)
        .opacity(inputDetail.opacity)

        .sheet(isPresented: $inputDetail.isPresentedEditItem) {

            // NOTE: itemがnilでない場合のみボタンを有効にしているため、ボタンアクション時には値を強制アンラップします。
            EditItemView(itemVM: itemVM,
                         inputHome: $inputHome,
                         itemIndex: inputHome.actionItemIndex,
                         passItemData: item,
                         editItemStatus: .update)
        } // sheet(アイテム更新シート)

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
