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

    let itemVM: ItemViewModel

    @State private var itemName = ""
    @State private var itemtag = ""
    @State private var itemStock = ""
    @State private var itemPlace = ""
    @State private var itemDetail = ""
    @State private var selectionTag = ""
    @State private var isButtonDisabled = true
    @State private var isOpenSideMenu = false
    @State private var geometryMinY = CGFloat(0)
    @FocusState private var focusedField: Field?

    var body: some View {

        NavigationView {

            ScrollView(showsIndicators: false) {

                ZStack {
                    VStack { // 全体

                        // ✅カスタムView
                        SelectItemPhotoArea(gradientColor1: .red, gradientColor2: .black)

                        // -------- 入力フォームここから ----------

                        VStack(spacing: 30) {

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■タグ設定", isNeed: true)
                                    .padding(.bottom)

                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.red)

                                    Picker("", selection: $selectionTag) {
                                        ForEach(0 ..< itemVM.tags.count, id: \.self) { index in

                                            if let tagsRow = itemVM.tags[index] {
                                                Text(tagsRow).tag(tagsRow)
                                            }
                                        }
                                        Text("＋タグを追加").tag("＋タグを追加")
                                    } // Picker
                                } // HStack(Pickerタグ要素)

                                // NOTE: フォーカスの有無によって、入力欄の下線の色をスイッチします。(カスタムView)
                                FocusedLineRow(select: focusedField == .tag ? true : false)

                            } // ■タグ設定

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■アイテム名", isNeed: true)
                                    .padding(.bottom)

                                TextField("1st Album「...」", text: $itemName)
                                    .focused($focusedField, equals: .name)
                                    .onTapGesture { focusedField = .name }
                                    .onSubmit { focusedField = .stock }

                                FocusedLineRow(select: focusedField == .name ? true : false)
                            } // ■アイテム名

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■在庫数", isNeed: false)
                                    .padding(.bottom)

                                TextField("100", text: $itemStock)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .stock)
                                    .onTapGesture { focusedField = .stock }

                                FocusedLineRow(select: focusedField == .stock ? true : false)
                            } // ■在庫数

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■価格(税込)", isNeed: false)
                                    .padding(.bottom)

                                TextField("2000", text: $itemPlace)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .place)
                                    .onTapGesture { focusedField = .place }

                                FocusedLineRow(select: focusedField == .place ? true : false)
                            } // ■価格

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■アイテム詳細(メモ)", isNeed: false)
                                    .font(.title3)

                                TextEditor(text: $itemDetail)
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 200)
                                    .shadow(radius: 3, x: 0, y: 0)
                                    .focused($focusedField, equals: .detail)
                                    .onTapGesture { focusedField = .detail }
                                    .overlay(alignment: .topLeading) {
                                        if focusedField != .detail {
                                            if itemDetail.isEmpty {
                                                Text("アイテムについてメモを残しましょう。")
                                                    .opacity(0.5)
                                                    .padding()
                                            }
                                        }
                                    } // overlay
                            } // ■アイテム詳細
                            .padding(.top)

                        } // VStack(入力フォーム全体)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 30)

                        // -------- 入力フォームここまで ----------

                    } // VStack

                    if isOpenSideMenu {

                        SideMenuNewTagView(itemVM: itemVM,
                                           isOpenSideMenu: $isOpenSideMenu,
                                           geometryMinY: $geometryMinY)
                    } // if isOpenSideMenu

                } // ZStack(View全体)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: OffsetPreferenceKey.self,
                                        value: geometry.frame(in: .named("scrollSpace")).minY)
                            .onChange(of: geometry.frame(in: .named("scrollFrame_Space")).minY) {newValue in
                                self.geometryMinY = newValue
                            }
                    } // Geometry
                ) // .background(geometry)

            } // ScrollView
            .coordinateSpace(name: "scrollFrame_Space")

            .onTapGesture { focusedField = nil }

            // NOTE: タグ選択で「+タグを追加」が選択された時、新規タグ追加Viewを表示します。
            .onChange(of: selectionTag) { selection in
                if selection == "＋タグを追加" {
                    self.isOpenSideMenu.toggle()
                    print("サイドメニュー: \(isOpenSideMenu)")
                }
            } // onChange

            // NOTE: 新規タグ追加Viewが閉じられた時、タグ配列の一番目を再代入します。
            //       新規作成されたタグは配列の１番目に格納するよう処理されます。
            .onChange(of: isOpenSideMenu) { newValue in
                if newValue == false {
                    if let firstTag = itemVM.tags.first {
                        selectionTag = firstTag
                    }
                }
            } // onChange

            // NOTE: 新規アイテムView生成時に、タグ配列の１番目の要素をPickerが参照するselectionTagに初期値として代入します。
            .onAppear {
                if let firstTag = itemVM.tags.first {
                    self.selectionTag = firstTag
                    print("onAppear時に格納したタグ: \(selectionTag)")
                }
            } // onAppear

            .navigationTitle("新規アイテム")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // アイテム追加
                    } label: {
                        Text("追加する")
                    }
                }
            } // toolbar

        } // NavigationView
    } // body
} // View

struct SelectItemPhotoArea: View {

    let gradientColor1: Color
    let gradientColor2: Color

    var body: some View {
        // -------- グラデーション部分ここから ----------

        LinearGradient(colors: [gradientColor1, gradientColor2], startPoint: .top, endPoint: .bottom)
            .frame(width: UIScreen.main.bounds.width, height: 350)
            .overlay {
                VStack {

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
                                // Todo: アイテム写真追加処理
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
    }
}

// NOTE: スクロールView全体に対しての画面の現在位置座標をgeometry内で検知し、値を渡すために用いる
private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView(itemVM: ItemViewModel())
    }
}
