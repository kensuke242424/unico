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
    let teamID: String

    struct InputItemDetail {
        var opacity: Double = 0
        var isShowEditHearAlert: Bool = false
        var isShowAmountAlert: Bool = false
        var isShowDeleteItemAlert: Bool = false
        var isPresentedEditItem: Bool = false
    }

    private let screenSize: CGRect = UIScreen.main.bounds
    @State private var inputDetail: InputItemDetail = InputItemDetail()

    var body: some View {

        ZStack {

            Color(.black).opacity(0.7)
                .background(.ultraThinMaterial).opacity(0.95)
                .ignoresSafeArea()
                .onTapGesture {
                    inputHome.isShowItemDetail.toggle()
                }

            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.black)
                .frame(width: screenSize.width * 0.75, height: screenSize.height * 0.55)
                .opacity(0.9)
                .overlay {
                    Color.red.opacity(0.5)
                        .blur(radius: 20)
                        .overlay(alignment: .bottom) {


                            Button {
                                inputHome.isShowItemDetail.toggle()
                            } label: {
                                Label("閉じる", systemImage: "multiply.circle.fill")
                                    .foregroundColor(.white)
                            }
                            .offset(y: 50)

                        }
                }

                .overlay {

                    VStack {
                        Text(item.name).fontWeight(.bold).foregroundColor(.white)
                            .tracking(1)
                            .lineLimit(1)

                        ScrollViewReader { scrollProxy in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 10) {

                                    ShowsItemAsyncImagePhoto(photoURL: item.photoURL, size: screenSize.width * 0.35)
                                        .padding()
                                        .id("top")

                                    HStack {
                                        Text("　アイテム情報")
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)

                                        Button {

                                            if item.amount != 0 {
                                                inputDetail.isShowAmountAlert.toggle()
                                                return
                                            }

                                            inputDetail.isShowEditHearAlert.toggle()

                                        } label: {
                                            Image(systemName: "highlighter")
                                                .foregroundColor(.yellow)

                                        }
                                        .offset(x: 10)
                                        .alert("確認", isPresented: $inputDetail.isShowEditHearAlert) {

                                            Button {
                                                inputDetail.isShowEditHearAlert.toggle()
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
                                            Text("\(item.name) を編集しますか？")
                                        } // alert

                                        .alert("編集", isPresented: $inputDetail.isShowAmountAlert) {

                                            Button("OK") {
                                                inputDetail.isShowAmountAlert.toggle()
                                            }
                                        } message: {
                                            Text("処理中のアイテムは編集できません")
                                        } // alert

                                        .alert("確認", isPresented: $inputDetail.isShowDeleteItemAlert) {

                                            Button("削除", role: .destructive) {
                                                inputHome.isShowItemDetail.toggle()

                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    withAnimation {
                                                        itemVM.items.removeAll(where: { $0.id == item.id })
                                                    }
                                                    Task {
                                                        await itemVM.deleteImage(path: item.photoPath)
                                                        itemVM.deleteItem(deleteItem: item, teamID: teamID)
                                                    }
                                                }
                                            }
                                            .foregroundColor(.red)
                                        } message: {
                                            Text("\(item.name) を削除しますか？")
                                        } // alert

                                    } // HStack

                                    Divider().background(.white).opacity(0.5)
                                        .padding()

                                    // NOTE: アイテムの情報が格納羅列されたカスタムViewです
                                    ItemDetailData(item: item)
                                        .offset(x: -10)

                                    Divider().background(.white).opacity(0.5)
                                        .padding()

                                    Text("Memo.")
                                        .foregroundColor(.white)

                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.gray).opacity(0.2)
                                        .frame(width: screenSize.width * 0.6, height: 300)
                                        .overlay(alignment: .topLeading) {
                                            ScrollView {
                                                Text(item.detail).font(.caption).foregroundColor(.white)
                                                    .padding(10)
                                            }
                                        }
                                    Button {
                                        // アイテム削除
                                        inputDetail.isShowDeleteItemAlert.toggle()
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .foregroundColor(.red)
                                                .frame(width: 35)
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.white)
                                        }
                                        .opacity(0.7)
                                    }
                                } // VStack
                                .onChange(of: inputHome.isShowItemDetail) { showValue in
                                    if showValue == false {
                                        scrollProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            } // ScrollView
                        }
                    } // VStack
                    .padding(.vertical, 30)
                }// overlay
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
                        item: sampleItems.first!,
                        teamID: "")
    }
}
