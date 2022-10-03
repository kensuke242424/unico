//
//  NewitemView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/03.
//

import SwiftUI

struct NewItemView: View {

    let screenSize = UIScreen.main.bounds

    @State private var itemName = ""
    @State private var itemtag = ""
    @State private var itemStock = ""
    @State private var itemPlace = ""
    @State private var itemDetail = ""

    var body: some View {

        NavigationView {

                VStack {

                    LinearGradient(colors: [.red, .black], startPoint: .top, endPoint: .bottom)
                        .frame(width: screenSize.width, height: screenSize.height / 2)
//                        .ignoresSafeArea(edges: .top)
                        .overlay {
                            VStack {
                                Text("New Item")
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .padding(.bottom)

//                                Spacer()

                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray)
                                    .frame(width: 270, height: 270)
                                    .opacity(0.6)
                                    .overlay {
                                        Text("No Image...")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                            .fontWeight(.black)
                                    }
                                    .overlay(alignment: .bottomTrailing) {
                                        Button {
                                            // アイテム写真追加処理
                                        } label: {
                                            Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .offset(x: 7, y: 7)
                                        } // Button
                                    } // .overlay(ボタン)
//                                Spacer()
                            } // VStack
                        } // .overlay

                    //                    ScrollView {
                    VStack(spacing: 20) {

                        VStack(spacing: 10) {


                            VStack(alignment: .leading) {
                                Text("■タグ設定")
                                TextField("ホイールで作成", text: $itemtag)
                                Divider()
                            } // タグ

                            VStack(alignment: .leading) {
                                // 機種によって表示どうなるか要検証
                                Text("■アイテム名")
                                TextField("1st Album「...」", text: $itemName)
                                Divider()
                            } // アイテム名


                            VStack(alignment: .leading) {
                                Text("■在庫数")
                                TextField("100", text: $itemStock)
                                Divider()
                            } // 在庫数

                            VStack(alignment: .leading) {
                                Text("■価格(税込)")
                                TextField("2000", text: $itemPlace)
                                Divider()
                            } // 価格

                        } // VStack(記入欄)
                        .padding()

                        TextEditor(text: $itemDetail)
                            .border(.gray, width: 1)
                            .cornerRadius(8)
                            .padding()
                            .overlay {
                                Text("アイテム詳細を記入してください。")
                                    .foregroundColor(.gray)
                            }
                    } // VStack
                    //                    } // ScrollView
                } // VStack

        } // NavigationView
    } // body

    // .topセーフエリアの幅を算出するメソッド
    func dispSize() -> CGFloat {
        var statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    } // func

} // View

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView()
    }
}
