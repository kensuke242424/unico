//
//  UpdateItemView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/08.
//

import SwiftUI

enum Status {
    case create
    case update
}

enum Field {
    case tag
    case name
    case stock
    case price
    case sales
    case detail
}

struct EditItemView: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var isPresentedEditItem: Bool

    let itemIndex: Int
    let editItemData: Item?

    // NOTE: enum「Status」を用いて、新規登録と編集とでViewレイアウトを分岐します。
    let editItemStatus: Status

    @State private var photoURL = ""  // Todo: 写真取り込み機能追加後使用
    @State private var selectionTagName = ""
    @State private var selectionTagColor = Color.red
    @State private var updateItemName = ""
    @State private var updateItemInventry = ""
    @State private var updateItemPrice = ""
    @State private var updateItemSales = ""
    @State private var updateItemDetail = ""
    @State private var disableButton = true
    @State private var isOpenSideMenu = false
    @State private var offset: CGFloat = 0
    @State private var geometryMinY: CGFloat = 0

    @FocusState private var focusedField: Field?

    var body: some View {

        NavigationView {

            ScrollView(showsIndicators: false) {

                ZStack {
                    VStack {

                        // ✅カスタムView 写真ゾーン
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

                                    Spacer()

                                    Button {

                                        isOpenSideMenu.toggle()

                                    } label: {
                                        Text("タグ編集>>")
                                    }
                                    .padding(.trailing)

                                } // HStack(Pickerタグ要素)

                                // NOTE: フォーカスの有無によって、入力欄の下線の色をスイッチします。(カスタムView)
                                FocusedLineRow(select: focusedField == .tag ? true : false)

                            } // ■タグ設定

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■アイテム名", isNeed: true)
                                    .padding(.bottom)

                                TextField("1st Album「...」", text: $updateItemName)
                                    .focused($focusedField, equals: .name)
                                    .autocapitalization(.none)
                                    .onTapGesture { focusedField = .name }
                                    .onSubmit { focusedField = .stock }

                                FocusedLineRow(select: focusedField == .name ? true : false)

                            } // ■アイテム名

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■在庫数", isNeed: false)
                                    .padding(.bottom)

                                TextField("100", text: $updateItemInventry)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .stock)
                                    .onTapGesture { focusedField = .stock }
                                    .onSubmit { focusedField = .price }

                                FocusedLineRow(select: focusedField == .stock ? true : false)

                            } // ■在庫数

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■価格(税込)", isNeed: false)
                                    .padding(.bottom)

                                TextField("2000", text: $updateItemPrice)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .price)
                                    .onTapGesture { focusedField = .price }
                                    .onSubmit { focusedField = .sales }

                                FocusedLineRow(select: focusedField == .price ? true : false)

                            } // ■価格

                            if editItemStatus == .update {

                                VStack(alignment: .leading) {

                                    InputFormTitle(title: "■総売上げ", isNeed: false)
                                        .padding(.bottom)

                                    TextField("2000", text: $updateItemSales)
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: .sales)
                                        .onTapGesture { focusedField = .sales
                                        }
                                        .onSubmit { focusedField = .sales }

                                    FocusedLineRow(select: focusedField == .sales ? true : false)

                                } // ■総売上
                            } // if .update「総売上」

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■アイテム詳細(メモ)", isNeed: false)
                                    .font(.title3)

                                TextEditor(text: $updateItemDetail)
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 200)
                                    .shadow(radius: 3, x: 0, y: 0)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .detail)
                                    .onTapGesture { focusedField = .detail }
                                    .overlay(alignment: .topLeading) {
                                        if focusedField != .detail {
                                            if updateItemDetail.isEmpty {
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

                    } // VStack(パーツ全体)

                    if isOpenSideMenu {

                        SideMenuEditTagView(
                            itemVM: itemVM,
                            isOpenSideMenu: $isOpenSideMenu,
                            geometryMinY: $geometryMinY,
                            selectionTagName: $selectionTagName,
                            selectionTagColor: $selectionTagColor,
                            itemTagName: selectionTagName,
                            itemTagColor: selectionTagColor,
                            editItemStatus: editItemStatus,
                            // Warning_TextSimbol: "＋タグを追加"
                            tagSideMenuStatus: selectionTagName == "＋タグを追加" ? .create : .update
                        )

                    } // if isOpenSideMenu

                } // ZStack(View全体)
                // アイテム詳細
                .offset(y: focusedField == .detail && -500.0 <= geometryMinY ? offset - 300 : 0)
                .animation(.easeIn(duration: 0.3), value: offset)

                // NOTE: スクロールView全体を.backgroundからgeometry取得します。
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: OffsetPreferenceKey.self,
                                        value: geometry.frame(in: .named("scrollSpace")).minY)
                            .onChange(of: geometry.frame(in: .named("scrollFrame_Space")).minY) { newValue in

                                withAnimation(.easeIn(duration: 0.1)) {
                                    //                                    print(newValue)
                                    self.geometryMinY = newValue
                                }
                            } // onChange
                    } // Geometry
                ) // .background(geometry)

            } // ScrollView
            .coordinateSpace(name: "scrollFrame_Space")

            .onTapGesture { focusedField = nil }

            .onChange(of: selectionTagName) { selection in

                //                // NOTE: 選択されたタグネームと紐づいたタグカラーを取り出し、selectionTagColorに格納します。
                let searchedTagColor = itemVM.searchSelectTagColor(selectTagName: selection,
                                                                   tags: itemVM.tags)
                withAnimation(.easeIn(duration: 0.25)) {
                    selectionTagColor = searchedTagColor
                }

                // NOTE: タグ選択で「+タグを追加」が選択された時、新規タグ追加Viewを表示します。
                // Warning_TextSimbol: "＋タグを追加"
                if selection == "＋タグを追加" {
                    self.isOpenSideMenu.toggle()
                    print("サイドメニュー: \(isOpenSideMenu)")
                }
            } // onChange (selectionTagName)

            .onChange(of: updateItemName) { newValue in

                withAnimation(.easeIn(duration: 0.2)) {
                    if newValue.isEmpty {
                        self.disableButton = true
                    } else {
                        self.disableButton = false
                    }
                }
            } // onChange(ボタンdisable分岐)

            // NOTE: タグ追加サイドメニュー表示後、新規タグが追加されず、サイドメニューが閉じられた時(タグ選択が「＋タグ選択」のままの状態)
            //       タグピッカーの選択をアイテムが保有するタグに戻します。
            .onChange(of: isOpenSideMenu) { isOpen in

                if isOpen == false {
                    // Warning_TextSimbol: "＋タグを追加"
                    if selectionTagName == "＋タグを追加" {

                        switch editItemStatus {

                        case .create:

                            if let defaultTag = itemVM.tags.first {
                                self.selectionTagName = defaultTag.tagName
                            }

                        case .update:

                            if let editItemData = editItemData {
                                selectionTagName = editItemData.tag
                            }
                        } // switch

                    } // if selectionTagName == "＋タグを追加"
                } // if isOpen == false
            } // onChange(サイドメニューが綴じられた後の選択タグ監視)

            // NOTE: updateitemView呼び出し時に、親Viewから受け取ったアイテム情報を各入力欄に格納します。
            .onAppear {

                print("EditItemView_onAppear_実行")

                print("アイテム編集ステータス: \(editItemStatus)")

                if let editItemData = editItemData {

                    self.selectionTagName = editItemData.tag
                    self.updateItemName = editItemData.name
                    self.updateItemInventry = String(editItemData.inventory)
                    self.updateItemPrice = String(editItemData.price)
                    self.updateItemSales = String(editItemData.sales)
                    self.updateItemDetail = editItemData.detail
                }
            } // onAppear

            .navigationTitle(editItemStatus == .create ? "新規アイテム" : "アイテム編集")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button {

                        // NOTE: Firestoreへのデータ保存を見越して、Color型はString型に変換しておきます。
                        let castTagColorString = itemVM.castColorIntoString(color: selectionTagColor)

                        switch editItemStatus {

                        case .create:

                            // NOTE: テストデータに新規アイテムを保存
                            itemVM.items.append(Item(tag: selectionTagName,
                                                     tagColor: castTagColorString,
                                                     name: updateItemName,
                                                     detail: updateItemDetail != "" ? updateItemDetail : "none.",
                                                     photo: "", // Todo: 写真取り込み実装後、変更
                                                     price: Int(updateItemPrice) ?? 0,
                                                     sales: 0,
                                                     inventory: Int(updateItemInventry) ?? 0,
                                                     createTime: Date(), // Todo: Timestamp実装後、変更
                                                     updateTime: Date())) // Todo: Timestamp実装後、変更

                            if let appendNewItem = itemVM.items.last {
                                print("新規追加されたアイテム: \(appendNewItem)")
                            }

                        case .update:
                            // NOTE: テストデータに情報の変更を保存
                            let updateItemSource = Item(tag: selectionTagName,
                                                        tagColor: castTagColorString,
                                                        name: updateItemName,
                                                        detail: updateItemDetail != "" ? updateItemDetail : "none.",
                                                        photo: "", // Todo: 写真取り込み実装後、変更
                                                        price: Int(updateItemPrice) ?? 0,
                                                        sales: Int(updateItemSales) ?? 0,
                                                        inventory: Int(updateItemInventry) ?? 0,
                                                        createTime: Date(), // Todo: Timestamp実装後、変更
                                                        updateTime: Date()) // Todo: Timestamp実装後、変更

                            // NOTE: アイテムを更新
                            itemVM.items[itemIndex] = updateItemSource

                            print("更新されたアイテム: \(itemVM.items[itemIndex])")

                        } // switch itemStatus

                        // シートを閉じる
                        self.isPresentedEditItem.toggle()

                    } label: {
                        Text(editItemStatus == .create ? "追加する" : "更新する")
                    }
                    .disabled(disableButton)
                }
            } // toolbar(アイテム追加ボタン)

        } // NavigationView
    } // body
} // View

// NOTE: スクロールView全体に対しての画面の現在位置座標をgeometry内で検知し、値を渡すために用いる
private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct UpdateItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView(itemVM: ItemViewModel(),
                        isPresentedEditItem: .constant(true),
                       itemIndex: 0,
                       editItemData:
                        Item(tag: "Album",
                             tagColor: "赤",
                             name: "Album1",
                             detail: "Album1のアイテム紹介テキストです。",
                             photo: "",
                             price: 1800,
                             sales: 88000,
                             inventory: 200,
                             createTime: Date(),
                             updateTime: Date()),
                       editItemStatus: .update
        )
    }
}
