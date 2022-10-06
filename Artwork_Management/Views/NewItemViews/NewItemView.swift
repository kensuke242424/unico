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
    case price
    case detail
}

struct NewItemView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var isPresentedNewItem: Bool

    @State private var selectionTagName = ""
    @State private var selectionTagColor = Color.red
    @State private var newItemName = ""
    @State private var newItemInventry = ""
    @State private var newItemPrice = ""
    @State private var newItemDetail = ""
    @State private var disableButton = true
    @State private var isOpenSideMenu = false
    @State private var geometryMinY = CGFloat(0)

    @FocusState private var focusedField: Field?

    var body: some View {

        NavigationView {

            ScrollView(showsIndicators: false) {

                ZStack {
                    VStack {

                        // ✅カスタムView
                        SelectItemPhotoArea(selectTagColor: selectionTagColor)

                        // -------- 入力フォームここから ---------- //

                        VStack(spacing: 30) {

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■タグ設定", isNeed: true)
                                    .padding(.bottom)

                                HStack {
                                    Image(systemName: "tag.fill")
                                    // NOTE: メソッドで選択タグと紐づいたカラーを取り出す
                                        .foregroundColor(selectionTagColor)

                                    Picker("", selection: $selectionTagName) {
                                        ForEach(0 ..< itemVM.tags.count, id: \.self) { index in

                                            if let tagsRow = itemVM.tags[index] {
                                                Text(tagsRow.tagName).tag(tagsRow.tagName)
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

                                TextField("1st Album「...」", text: $newItemName)
                                    .focused($focusedField, equals: .name)
                                    .onTapGesture { focusedField = .name }
                                    .onSubmit { focusedField = .stock }

                                FocusedLineRow(select: focusedField == .name ? true : false)

                            } // ■アイテム名

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■在庫数", isNeed: false)
                                    .padding(.bottom)

                                TextField("100", text: $newItemInventry)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .stock)
                                    .onTapGesture { focusedField = .stock }
                                    .onSubmit { focusedField = .price }

                                FocusedLineRow(select: focusedField == .stock ? true : false)

                            } // ■在庫数

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■価格(税込)", isNeed: false)
                                    .padding(.bottom)

                                TextField("2000", text: $newItemPrice)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .price)
                                    .onTapGesture { focusedField = .price }
                                    .onSubmit { focusedField = .detail }

                                FocusedLineRow(select: focusedField == .price ? true : false)

                            } // ■価格

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■アイテム詳細(メモ)", isNeed: false)
                                    .font(.title3)

                                TextEditor(text: $newItemDetail)
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 200)
                                    .shadow(radius: 3, x: 0, y: 0)
                                    .focused($focusedField, equals: .detail)
                                    .onTapGesture { focusedField = .detail }
                                    .overlay(alignment: .topLeading) {
                                        if focusedField != .detail {
                                            if newItemDetail.isEmpty {
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

                        // -------- 入力フォームここまで ---------- //

                    } // VStack

                    if isOpenSideMenu {

                        SideMenuNewTagView(itemVM: itemVM,
                                           isOpenSideMenu: $isOpenSideMenu,
                                           geometryMinY: $geometryMinY
                        )
                    } // if isOpenSideMenu

                } // ZStack(View全体)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: OffsetPreferenceKey.self,
                                        value: geometry.frame(in: .named("scrollSpace")).minY)
                            .onChange(of: geometry.frame(in: .named("scrollFrame_Space")).minY) { newValue in

                                withAnimation(.easeIn(duration: 0.1)) {
                                    self.geometryMinY = newValue
                                }
                            } // onChange
                    } // Geometry
                ) // .background(geometry)

            } // ScrollView
            .coordinateSpace(name: "scrollFrame_Space")

            .onTapGesture { focusedField = nil }

            .onChange(of: selectionTagName) { selection in

                // NOTE: 選択されたタグネームと紐づいたタグカラーを取り出し、selectionTagColorに格納します。
                let searchedTagColor = itemVM.searchSelectTagColor(selectTagName: selection,
                                                                   tags: itemVM.tags)
                withAnimation(.easeIn(duration: 0.25)) {
                    selectionTagColor = searchedTagColor
                }

                // NOTE: タグ選択で「+タグを追加」が選択された時、新規タグ追加Viewを表示します。
                if selection == "＋タグを追加" {
                    self.isOpenSideMenu.toggle()
                    print("サイドメニュー: \(isOpenSideMenu)")
                }
            } // onChange (selectionTagName)

            .onChange(of: newItemName) { newValue in

                withAnimation(.easeIn(duration: 0.2)) {
                    if newValue.isEmpty {
                        self.disableButton = true
                    } else {
                        self.disableButton = false
                    }
                }
            } // onChange(ボタンdisable分岐)

            // NOTE: 新規タグ追加サイドViewが閉じられた時、タグ配列の一番目を再代入します。
            //       新規作成されたタグは配列の１番目に格納するよう処理されています。
            .onChange(of: isOpenSideMenu) { isOpen in

                if isOpen == false {
                    if let firstTag = itemVM.tags.first {
                        selectionTagName = firstTag.tagName
                    }
                }
            } // onChange(タグ設定内の選択タグ更新)

            // NOTE: NewItemView生成時に、タグ配列のfirst要素をPickerが参照するselectionTagに初期値として代入します。
            .onAppear {
                if let firstTag = itemVM.tags.first {
                    self.selectionTagName = firstTag.tagName
                    print("onAppear時に格納したタグ: \(selectionTagName)")
                }
            } // onAppear

            .navigationTitle("新規アイテム")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button {

                        print("追加ボタンタップ_selectionTagColor: \(selectionTagColor)")

                        let castTagColorString = itemVM.castColorIntoString(color: selectionTagColor)

                        print("追加ボタンタップ_castTagColorString: \(castTagColorString)")

                        // NOTE: テストデータに新規アイテムを保存
                        itemVM.items.append(Item(tag: selectionTagName,
                                                 tagColor: castTagColorString,
                                                 name: newItemName,
                                                 detail: newItemDetail != "" ? newItemDetail : "none.",
                                                 photo: "", // Todo: 写真取り込み実装後、変更
                                                 price: Int(newItemPrice) ?? 0,
                                                 sales: 0,
                                                 inventory: Int(newItemInventry) ?? 0,
                                                 createTime: Date(), // Todo: Timestamp実装後、変更
                                                 updateTime: Date()) // Todo: Timestamp実装後、変更
                        )

                        print("アイテム追加後の配列: \(itemVM.items.last!)")

                        // シートを閉じる
                        self.isPresentedNewItem.toggle()

                    } label: {
                        Text("追加する")
                    }
                    .disabled(disableButton)
                }
            } // toolbar(アイテム追加ボタン)

        } // NavigationView
    } // body
} // View

struct SelectItemPhotoArea: View {

    let selectTagColor: Color

    var body: some View {

        selectTagColor
            .frame(width: UIScreen.main.bounds.width, height: 350)
            .blur(radius: 2.0, opaque: false)

            .overlay {
                LinearGradient(colors: [Color.clear, Color.black], startPoint: .top, endPoint: .bottom)
            }

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
    } // body
} // カスタムView

// NOTE: スクロールView全体に対しての画面の現在位置座標をgeometry内で検知し、値を渡すために用いる
private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView(itemVM: ItemViewModel(), isPresentedNewItem: .constant(true))
    }
}
