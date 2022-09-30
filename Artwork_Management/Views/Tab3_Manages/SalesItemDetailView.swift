//
//  SalesItemDetailView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/30.
//

import SwiftUI

struct SalesItemDetailView: View {

    let name: String
    let sales: Int
    let price: Int
    let inventory: Int
    let photo: String
    let size = UIScreen.main.bounds
    @State private var opacity: Double = 0

    @State private var isShowAlert = false
    @State private var isShowItemEdit = false
    @Binding var isShowitemDetail: Bool

    var body: some View {

        ZStack {

            Color(.gray)
                .ignoresSafeArea()
                .opacity(0.3)

        RoundedRectangle (cornerRadius: 20)
            .frame(width: size.width / 1.3, height: size.height / 2)
            .opacity(0.5)

                VStack(spacing: 10) {
                    Text(name)
                        .fontWeight(.black)
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: 170, height: 170)
                        .foregroundColor(.yellow)

                    HStack {
                        Text("　アイテム情報")
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Button {
                            // NOTE: アイテム編集画面へ遷移するかをアラートで選択
                            isShowAlert.toggle()
                            
                        } label: {
                            Image(systemName: "highlighter")
                                .foregroundColor(.yellow)
                        }
                        .alert("編集", isPresented: $isShowAlert) {

                            Button {
                                isShowItemEdit.toggle()
                                print("isShowItemEdit: \(isShowItemEdit)")
                            } label: {
                                Text("戻る")
                            }

                            Button {
                                isShowItemEdit.toggle()
                                print("isShowItemEdit: \(isShowItemEdit)")
                            } label: {
                                Text("はい")
                            }
                        } message: {
                            Text("アイテム情報を編集しますか？")
                        } // alert
                    } // HStack

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                    // NOTE: アイテムの情報が格納羅列されたカスタムViewです
                    SalesItemContents(sales: sales, price: price, inventory: inventory)

                    Text("ーーーーーーーーーーーーー")
                        .foregroundColor(.white)

                } // VStack
            } // ZStack
        .onAppear {
            withAnimation(.linear(duration: 0.3)) {
                self.opacity = 1.0
            }
        }
    } // body
} // View

struct SalesItemContents: View {

    let sales: Int
    let price: Int
    let inventory: Int

    var body: some View {


        VStack(alignment: .listRowSeparatorLeading, spacing: 20) {

            HStack {

                Text("在庫残り　:　　")
                Text("\(inventory) 個")

            } // HStack

            HStack {

                Text("価格　　　:　　")
                Text("\(price) 円")

            } // HStack

            HStack {

                Text("総売上　　:　　")
                Text("\(sales) 円")

            } // HStack
        } // VStack
        .fontWeight(.light)
        .foregroundColor(.white)

    } // body
} // View

struct SalesItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SalesItemDetailView(name: "Album1", sales: 220000, price: 1800, inventory: 290, photo: "", isShowitemDetail: .constant(false))
    }
}
