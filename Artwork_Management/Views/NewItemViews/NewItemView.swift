//
//  NewitemView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/03.
//

import SwiftUI

enum Field {
    case tag
    case name
    case stock
    case place
    case detail
}

struct NewItemView: View {

    let screenSize = UIScreen.main.bounds

    @State private var itemName = ""
    @State private var itemtag = ""
    @State private var itemStock = ""
    @State private var itemPlace = ""
    @State private var itemDetail = ""
    @State private var scrollID = 0
    @FocusState private var focusedField: Field?

    var body: some View {

        NavigationView {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {

                    VStack { // 全体

                        // -------- グラデーション部分ここから ----------

                        LinearGradient(colors: [.red, .brown], startPoint: .top, endPoint: .bottom)
                            .frame(width: screenSize.width, height: screenSize.height / 2)
                            .overlay {
                                VStack {
                                    Text("New Item")
                                        .font(.title2)
                                        .fontWeight(.black)

                                    Rectangle()
                                        .frame(height: 1)
                                        .opacity(0.3)
                                        .shadow(radius: 4, x: 2)
                                        .padding(.horizontal, 50)
                                        .padding(.bottom, 20)

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
                                } // VStack
                            } // .overlay

                        // -------- グラデーション部分ここまで ----------
                        // -------- 入力フォームここから ----------

                        VStack(spacing: 20) {

                            VStack(alignment: .leading) {
                                Text("■タグ設定")
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                TextField("ホイールで作成", text: $itemtag)
                                    .focused($focusedField, equals: .tag)
                                    .onTapGesture {
                                        focusedField = .tag
                                    }

                                FocusedLineRow(select: focusedField == .tag ? true : false)

                            } // タグ

                            VStack(alignment: .leading) {
                                // 機種によって表示どうなるか要検証
                                Text("■アイテム名")
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                TextField("1st Album「...」", text: $itemName)
                                    .focused($focusedField, equals: .name)
                                    .onTapGesture {
                                        focusedField = .name
                                    }
                                    .onSubmit { focusedField = .stock }

                                FocusedLineRow(select: focusedField == .name ? true : false)
                            } // アイテム名

                            VStack(alignment: .leading) {
                                Text("■在庫数")
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                TextField("100", text: $itemStock)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .stock)
                                    .onTapGesture {
                                        focusedField = .stock
                                    }

                                FocusedLineRow(select: focusedField == .stock ? true : false)
                            } // 在庫数

                            VStack(alignment: .leading) {
                                Text("■価格(税込)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                TextField("2000", text: $itemPlace)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .place)
                                    .onTapGesture {
                                        focusedField = .place
                                    }

                                FocusedLineRow(select: focusedField == .place ? true : false)
                            } // 価格

                            VStack(alignment: .leading) {

                                Text("■アイテム詳細").id(1)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)

                                TextEditor(text: $itemDetail)
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 200)
                                    .shadow(radius: 3, x: 0, y: 0)
                                    .focused($focusedField, equals: .detail)
                                    .onTapGesture {
                                        focusedField = .detail
                                        self.scrollID = 1
                                    }
                                    .overlay(alignment: .topLeading) {
                                        if focusedField != .detail {
                                            if itemDetail.isEmpty {
                                                Text("アイテムについてメモを残しましょう。")
                                                    .opacity(0.3)
                                                    .padding()
                                            }
                                        }
                                    } // overlay
                            } // アイテム詳細
                            .padding(.top)
                        } // VStack(記入欄)
                        .padding()

                        // -------- 入力フォームここまで ----------

                    } // VStack 全体
                    .onTapGesture { focusedField = nil }
                } // ScrollView
                .onChange(of: scrollID) { id in
                    withAnimation {
                        proxy.scrollTo(id)
                    }
                } // onChange
            .navigationTitle("新規アイテム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        // アイテム追加処理
                    } label: {
                        Text("追加する")
                    }
                }
            } // .toolbar
            } // ScrollReader
        } // NavigationView
    } // body
} // View

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView()
    }
}
