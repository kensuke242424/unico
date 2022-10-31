//
//  UpdateItemView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/08.
//

import SwiftUI

struct EditItemView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var isPresentedEditItem: Bool

    let itemIndex: Int
    let passItemData: Item?

    // NOTE: enum「Status」を用いて、「.create」と「.update」とでViewレイアウトを分岐します。
    let editItemStatus: Status

    // NOTE: ＠Stateの入力プロパティを構造体化
    struct InputEditItem {

        var selectionTagName: String = ""
        var selectionTagColor: UsedColor = .red
        var photoURL: String = ""  // Todo: 写真取り込み機能追加後使用
        var editItemName: String = ""
        var editItemInventry: String = ""
        var editItemPrice: String = ""
        var editItemSales: String = ""
        var editItemDetail: String = ""
        var disableButton: Bool = true
        var isOpenSideMenu: Bool = false
        var offset: CGFloat = 0
        var geometryMinY: CGFloat = 0
        var isCheckedFocuseDetail: Bool = false
    }
    @State private var inputEdit: InputEditItem = InputEditItem()

    var body: some View {

        NavigationView {

            ScrollView(showsIndicators: false) {

                ZStack {
                    Color.customDarkGray1
                        .ignoresSafeArea()
                        .overlay {
                            LinearGradient(gradient: Gradient(colors:
                                                                [.clear, .customLightGray1]),
                                                       startPoint: .top, endPoint: .bottom)
                        }
                        .offset(y: 340)
                    VStack {
                        // ✅カスタムView 写真ゾーン
                        SelectItemPhotoArea(item: passItemData)

                        InputForms(itemVM: itemVM,
                                   selectionTagName: $inputEdit.selectionTagName,
                                   isOpenSideMenu: $inputEdit.isOpenSideMenu,
                                   editItemName: $inputEdit.editItemName,
                                   editItemInventry: $inputEdit.editItemInventry,
                                   editItemPrice: $inputEdit.editItemPrice,
                                   editItemSales: $inputEdit.editItemSales,
                                   editItemDetail: $inputEdit.editItemDetail,
                                   geometryMinY: $inputEdit.geometryMinY,
                                   offset: $inputEdit.offset,
                                   editItemStatus: editItemStatus,
                                   tagColor: inputEdit.selectionTagColor)

                    } // VStack(パーツ全体)

                    if inputEdit.isOpenSideMenu {

                        SideMenuEditTagView(
                            itemVM: itemVM,
                            isOpenSideMenu: $inputEdit.isOpenSideMenu,
                            geometryMinY: $inputEdit.geometryMinY,
                            selectionTagName: $inputEdit.selectionTagName,
                            selectionTagColor: $inputEdit.selectionTagColor,
                            itemTagName: inputEdit.selectionTagName,
                            itemTagColor: inputEdit.selectionTagColor,
                            editItemStatus: editItemStatus,
                            // Warning_TextSimbol: "＋タグを追加"
                            tagSideMenuStatus: inputEdit.selectionTagName == "＋タグを追加" ? .create : .update)
                    } // if isOpenSideMenu

                } // ZStack(View全体)
                .animation(.easeIn(duration: 0.3), value: inputEdit.offset)

                // NOTE: スクロールView全体を.backgroundからgeometry取得します。
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: OffsetPreferenceKey.self,
                                        value: geometry.frame(in: .named("scrollSpace")).minY)
                            .onChange(of: geometry.frame(in: .named("scrollFrame_Space")).minY) { newValue in

                                withAnimation(.easeIn(duration: 0.1)) {
                                    inputEdit.geometryMinY = newValue
                                }
                            } // onChange
                    } // Geometry
                ) // .background(geometry)

            } // ScrollView
            .coordinateSpace(name: "scrollFrame_Space")

            .onChange(of: inputEdit.selectionTagName) { selection in

                // NOTE: 選択されたタグネームと紐づいたタグカラーを取り出し、selectionTagColorに格納します。
                let searchedTagColor = itemVM.searchSelectTagColor(selectTagName: selection,
                                                                   tags: itemVM.tags)
                withAnimation(.easeIn(duration: 0.25)) {
                    inputEdit.selectionTagColor = searchedTagColor
                }

                // NOTE: タグ選択で「+タグを追加」が選択された時、新規タグ追加Viewを表示します。
                // Warning_TextSimbol: "＋タグを追加"
                if selection == "＋タグを追加" {
                    inputEdit.isOpenSideMenu.toggle()
                }
            } // onChange (selectionTagName)

            .onChange(of: inputEdit.editItemName) { newValue in

                withAnimation(.easeIn(duration: 0.2)) {
                    if newValue.isEmpty {
                        inputEdit.disableButton = true
                    } else {
                        inputEdit.disableButton = false
                    }
                }
            } // onChange(ボタンdisable分岐)

            // NOTE: タグ追加サイドメニュー表示後、新規タグが追加されず、サイドメニューが閉じられた時(タグ選択が「＋タグ選択」のままの状態)
            //       タグピッカーの選択をアイテムが保有するタグに戻します。
            .onChange(of: inputEdit.isOpenSideMenu) { isOpen in

                if isOpen == false {
                    // Warning_TextSimbol: "＋タグを追加"
                    if inputEdit.selectionTagName == "＋タグを追加" {

                        switch editItemStatus {

                        case .create:
                            if let defaultTag = itemVM.tags.first {
                                inputEdit.selectionTagName = defaultTag.tagName
                            }

                        case .update:
                            if let editItemData = passItemData {
                                inputEdit.selectionTagName = editItemData.tag
                            }
                        } // switch

                    } // if selectionTagName == "＋タグを追加"
                } // if isOpen == false
            } // onChange(サイドメニューが綴じられた後の選択タグ監視)

            // NOTE: updateitemView呼び出し時に、親Viewから受け取ったアイテム情報を各入力欄に格納します。
            .onAppear {

                print("EditItemView_onAppear")

                print("アイテム編集ステータス: \(editItemStatus)")

                // NOTE: 新規アイテム登録遷移の場合、passItemDataにはnilが代入されている
                if let passItemData = passItemData {

                    inputEdit.selectionTagName = passItemData.tag
                    inputEdit.editItemName = passItemData.name
                    inputEdit.editItemInventry = String(passItemData.inventory)
                    inputEdit.editItemPrice = String(passItemData.price)
                    inputEdit.editItemSales = String(passItemData.sales)
                    inputEdit.editItemDetail = passItemData.detail

                } else {
                    guard let defaultTag = itemVM.tags.first else { return }
                    inputEdit.selectionTagName = defaultTag.tagName
                }

            } // onAppear

            .navigationTitle(editItemStatus == .create ? "新規アイテム" : "アイテム編集")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button {

                        switch editItemStatus {

                        case .create:

                            // NOTE: テストデータに新規アイテムを保存
                            itemVM.items.append(Item(tag: inputEdit.selectionTagName,
                                                     tagColor: inputEdit.selectionTagColor.text,
                                                     name: inputEdit.editItemName,
                                                     detail: inputEdit.editItemDetail != "" ? inputEdit.editItemDetail : "none.",
                                                     photo: "", // Todo: 写真取り込み実装後、変更
                                                     cost: 1000,
                                                     price: Int(input.editItemPrice) ?? 0,
                                                     sales: 0,
                                                     inventory: Int(input.editItemInventry) ?? 0,
                                                     totalAmount: 0,
                                                     totalInventory: 0,
                                                     createTime: Date(), // Todo: Timestamp実装後、変更
                                                     updateTime: Date())) // Todo: Timestamp実装後、変更

                            if let appendNewItem = itemVM.items.last {
                                print("新規追加されたアイテム: \(appendNewItem)")
                            }

                        case .update:

                            itemVM.items[itemIndex].tag = input.selectionTagName
                            itemVM.items[itemIndex].tagColor = input.selectionTagColor.text
                            itemVM.items[itemIndex].name = input.editItemName
                            itemVM.items[itemIndex].detail = input.editItemDetail != "" ? input.editItemDetail : "none."
                            itemVM.items[itemIndex].photo = "" // Todo: 写真取り込み実装後、変更
                            itemVM.items[itemIndex].price = Int(input.editItemPrice) ?? 0
                            itemVM.items[itemIndex].sales = Int(input.editItemSales) ?? 0
                            itemVM.items[itemIndex].inventory = Int(input.editItemInventry) ?? 0

                            print("更新されたアイテム: \(itemVM.items[itemIndex])")

                        } // switch editItemStatus(データ追加、更新)

                        // シートを閉じる
                        isPresentedEditItem.toggle()

                    } label: {
                        Text(editItemStatus == .create ? "追加する" : "更新する")
                    }
                    .disabled(inputEdit.disableButton)
                }
            } // toolbar(アイテム追加ボタン)

        } // NavigationView
    } // body
} // View

struct InputForms: View {

    enum EditItemField {
        case tag, name, stock, price, sales, detail
    }

    @StateObject var itemVM: ItemViewModel
    @Binding var selectionTagName: String
    @Binding var isOpenSideMenu: Bool
    @Binding var editItemName: String
    @Binding var editItemInventry: String
    @Binding var editItemPrice: String
    @Binding var editItemSales: String
    @Binding var editItemDetail: String
    @Binding var geometryMinY: CGFloat
    @Binding var offset: CGFloat

    // NOTE: enum「Status」を用いて、「.create」と「.update」とでViewレイアウトを分岐します。
    let editItemStatus: Status
    let tagColor: UsedColor

    @FocusState private var focusedField: EditItemField?

    var body: some View {

        VStack(spacing: 40) {

            VStack(alignment: .leading) {
                InputFormTitle(title: "■タグ設定", isNeed: true)
                    .padding(.bottom)

                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(tagColor.color)
                    Picker("", selection: $selectionTagName) {
                        ForEach(0 ..< itemVM.tags.count, id: \.self) { index in

                            if index != 0 {
                                Text(itemVM.tags[index].tagName).tag(itemVM.tags[index].tagName)
                            }
                        } // ForEach
                        Text("＋タグを追加").tag("＋タグを追加")
                    } // Picker

                    Spacer()

                    Button {
                        isOpenSideMenu.toggle()
                    } label: { Text("タグ編集>>") }
                    .padding(.trailing)
                } // HStack(Pickerタグ要素)

                // NOTE: フォーカスの有無によって、入力欄の下線の色をスイッチします。(カスタムView)
                FocusedLineRow(select: focusedField == .tag ? true : false)

            } // ■タグ設定

            VStack(alignment: .leading) {

                InputFormTitle(title: "■アイテム名", isNeed: true)
                    .padding(.bottom)

                TextField("1st Album「...」", text: $editItemName)
                    .foregroundColor(.white)
                    .focused($focusedField, equals: .name)
                    .autocapitalization(.none)
                    .onTapGesture { focusedField = .name }
                    .onSubmit { focusedField = .stock }

                FocusedLineRow(select: focusedField == .name ? true : false)

            } // ■アイテム名

            VStack(alignment: .leading) {

                InputFormTitle(title: "■在庫数", isNeed: false)
                    .padding(.bottom)

                TextField("100", text: $editItemInventry)
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .stock)
                    .onTapGesture { focusedField = .stock }
                    .onSubmit { focusedField = .price }

                FocusedLineRow(select: focusedField == .stock ? true : false)

            } // ■在庫数

            VStack(alignment: .leading) {

                InputFormTitle(title: "■価格(税込)", isNeed: false)
                    .padding(.bottom)

                TextField("2000", text: $editItemPrice)
                    .foregroundColor(.white)
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

                    TextField("2000", text: $editItemSales)
                        .foregroundColor(.white)
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

                TextEditor(text: $editItemDetail)
                    .frame(height: 200)
                    .shadow(radius: 3, x: 0, y: 0)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .detail)
                    .onTapGesture { focusedField = .detail }
                    .overlay(alignment: .topLeading) {
                        if focusedField != .detail {
                            if editItemDetail.isEmpty {
                                Text("アイテムについてメモを残しましょう。")
                                    .opacity(0.5)
                                    .padding()
                            }
                        }
                    } // overlay
                    .opacity(0.6)
            } // ■アイテム詳細
            .padding(.top)

        } // VStack(入力フォーム全体)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .onTapGesture { focusedField = nil }
    }
}

// NOTE: スクロールView全体に対しての画面の現在位置座標をgeometry内で検知し、値を渡すために用いる
private struct OffsetPreferenceKey: PreferenceKey, Equatable {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView(itemVM: ItemViewModel(),
                     isPresentedEditItem: .constant(true),
                     itemIndex: 0,
                     passItemData: TestItem().testItem,
                     editItemStatus: .update
        )
    }
}
