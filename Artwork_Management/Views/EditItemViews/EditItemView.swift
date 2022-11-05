//
//  UpdateItemView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/08.
//

import SwiftUI

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
    var offset: CGFloat = 0
    var isCheckedFocuseDetail: Bool = false
}

struct EditItemView: View {

    @StateObject var itemVM: ItemViewModel
    @Binding var inputHome: InputHome

    let itemIndex: Int
    let passItemData: Item?

    // NOTE: enum「EditStatus」を用いて、「.create」と「.update」とでViewレイアウトを分岐します。
    let editItemStatus: EditStatus

    // NOTE: ＠Stateの入力プロパティを構造体化

    @State private var inputEdit: InputEditItem = InputEditItem()
    @State private var inputTag: InputTagSideMenu = InputTagSideMenu()

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
                                   inputEdit: $inputEdit,
                                   isOpenEditTagSideMenu: $inputHome.isOpenEditTagSideMenu,
                                   editItemStatus: editItemStatus,
                                   passItem: passItemData)

                    } // VStack(パーツ全体)
                } // ZStack(View全体)
                .animation(.easeIn(duration: 0.3), value: inputEdit.offset)

            } // ScrollView

            .onChange(of: inputEdit.selectionTagName) { selection in

                // NOTE: 選択されたタグネームと紐づいたタグカラーを取り出し、selectionTagColorに格納します。
                let searchedTagColor = itemVM.searchSelectTagColor(selectTagName: selection,
                                                                   tags: itemVM.tags)
                withAnimation(.easeIn(duration: 0.25)) {
                    inputEdit.selectionTagColor = searchedTagColor
                }
            }

            .onChange(of: inputEdit.editItemName) { newValue in

                withAnimation(.easeIn(duration: 0.2)) {
                    if newValue.isEmpty {
                        inputEdit.disableButton = true
                    } else {
                        inputEdit.disableButton = false
                    }
                }
            } // onChange(ボタンdisable分岐)

            // NOTE: updateitemView呼び出し時に、親Viewから受け取ったアイテム情報を各入力欄に格納します。
            .onAppear {

                // NOTE: 新規アイテム登録遷移の場合、passItemDataにはnilが代入されている
                if let passItemData = passItemData {

                    inputEdit.selectionTagName = passItemData.tag
                    inputEdit.photoURL = passItemData.photo
                    inputEdit.editItemName = passItemData.name
                    inputEdit.editItemInventry = String(passItemData.inventory)
                    inputEdit.editItemPrice = String(passItemData.price)
                    inputEdit.editItemSales = String(passItemData.sales)
                    inputEdit.editItemDetail = passItemData.detail

                } else {
                    // tags[0]には"ALL"があるため、一つ飛ばして[1]を初期値として代入
                    inputEdit.selectionTagName = itemVM.tags[1].tagName
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
                            inputHome.isPresentedEditItem.toggle()

                        case .update:
                            // NOTE: テストデータに情報の変更を保存

                            // NOTE: アイテムを更新
                            itemVM.items[itemIndex].tag = inputEdit.selectionTagName
                            itemVM.items[itemIndex].tagColor = inputEdit.selectionTagColor.text
                            itemVM.items[itemIndex].name = inputEdit.editItemName
                            itemVM.items[itemIndex].detail = inputEdit.editItemDetail != "" ? inputEdit.editItemDetail : "none."
                            itemVM.items[itemIndex].photo = inputEdit.photoURL
                            itemVM.items[itemIndex].price = Int(inputEdit.editItemPrice) ?? 0
                            itemVM.items[itemIndex].sales = Int(inputEdit.editItemSales) ?? 0
                            itemVM.items[itemIndex].inventory = Int(inputEdit.editItemInventry) ?? 0
                            itemVM.items[itemIndex].updateTime = Date() // Todo: Timestamp実装後、変更
                            print("更新されたアイテム: \(itemVM.items[itemIndex])")

                            inputHome.isPresentedEditItem.toggle()

                        } // switch editItemStatus(データ追加、更新)
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
    @Binding var inputEdit: InputEditItem
    @Binding var isOpenEditTagSideMenu: Bool

    // NOTE: enum「Status」を用いて、「.create」と「.update」とでViewレイアウトを分岐します。
    let editItemStatus: EditStatus
    let passItem: Item?

    @FocusState private var focusedField: EditItemField?

    var body: some View {

        VStack(spacing: 40) {

            VStack(alignment: .leading) {
                InputFormTitle(title: "■タグ設定", isNeed: true)
                    .padding(.bottom)

                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(inputEdit.selectionTagColor.color)
                    Picker("", selection: $inputEdit.selectionTagName) {

                        if passItem?.tag == itemVM.tags.last!.tagName {

                            ForEach(itemVM.tags) { tag in
                                if tag != itemVM.tags.first! {
                                    Text(tag.tagName).tag(tag.tagName)
                                }
                            }

                        } else {

                            ForEach(itemVM.tags) { tag in
                                if tag != itemVM.tags.first! && tag != itemVM.tags.last! {
                                    Text(tag.tagName).tag(tag.tagName)
                                }
                            }
                        }
                    } // Picker

                    Spacer()

                } // HStack(Pickerタグ要素)

                // NOTE: フォーカスの有無によって、入力欄の下線の色をスイッチします。(カスタムView)
                FocusedLineRow(select: focusedField == .tag ? true : false)

            } // ■タグ設定

            VStack(alignment: .leading) {

                InputFormTitle(title: "■アイテム名", isNeed: true)
                    .padding(.bottom)

                TextField("1st Album「...」", text: $inputEdit.editItemName)
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

                TextField("100", text: $inputEdit.editItemInventry)
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

                TextField("2000", text: $inputEdit.editItemPrice)
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

                    TextField("2000", text: $inputEdit.editItemSales)
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

                TextEditor(text: $inputEdit.editItemDetail)
                    .frame(height: 300)
                    .shadow(radius: 3, x: 0, y: 0)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .detail)
                    .onTapGesture { focusedField = .detail }
                    .overlay(alignment: .topLeading) {
                        if focusedField != .detail {
                            if inputEdit.editItemDetail.isEmpty {
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
                     inputHome: .constant(InputHome()),
                     itemIndex: 0,
                     passItemData: TestItem().testItem,
                     editItemStatus: .update
        )
    }
}
