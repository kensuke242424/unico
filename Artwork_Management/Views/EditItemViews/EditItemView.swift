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
    var editItemInventory: String = ""
    var editItemCost: String = ""
    var editItemPrice: String = ""
    var editItemSales: String = ""
    var editItemDetail: String = ""
    var editItemTotalAmount: String = ""
    var editItemTotalInventry: String = ""
    var disableButton: Bool = true
    var offset: CGFloat = 0
    var isCheckedFocuseDetail: Bool = false
}

struct EditItemView: View {

    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel
    @Binding var inputHome: InputHome
    @Binding var inputImage: InputImage

    let userID: String // Todo: ユーザID取得次第、引数で受け取る
    let itemIndex: Int
    let passItemData: Item?
    let editItemStatus: EditStatus

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
                        EditItemPhotoArea(item: passItemData)

                        InputForms(itemVM: itemVM,
                                   tagVM: tagVM,
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
                let searchedTagColor = tagVM.filterTagsData(selectTagName: selection)
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
                    inputEdit.editItemInventory = String(passItemData.inventory)
                    inputEdit.editItemCost = String(passItemData.cost)
                    inputEdit.editItemPrice = String(passItemData.price)
                    inputEdit.editItemSales = String(passItemData.sales)
                    inputEdit.editItemDetail = passItemData.detail
                    inputEdit.editItemTotalAmount = String(passItemData.totalAmount)
                    inputEdit.editItemTotalInventry = String(passItemData.totalInventory)

                } else {
                    // tags[0]には"ALL"があるため、一つ飛ばして[1]を初期値として代入
                    inputEdit.selectionTagName = tagVM.tags[1].tagName
                }

            } // onAppear

            .navigationTitle(editItemStatus == .create ? "新規アイテム" : "アイテム編集")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button {

                        switch editItemStatus {

                        case .create:

                            guard let inputPrice = Int(inputEdit.editItemPrice) else { return }
                            guard let inputInventory = Int(inputEdit.editItemInventory) else { return }

                            // NOTE: テストデータに新規アイテムを保存
                            let itemData = (Item(tag: inputEdit.selectionTagName,
                                                 name: inputEdit.editItemName,
                                                 detail: inputEdit.editItemDetail != "" ? inputEdit.editItemDetail : "メモなし",
                                                 photo: "", // Todo: 写真取り込み実装後、変更
                                                 cost: 0,
                                                 price: inputPrice,
                                                 amount: 0,
                                                 sales: 0,
                                                 inventory: inputInventory,
                                                 totalAmount: 0,
                                                 totalInventory: inputInventory))

                            // Firestoreにコーダブル保存
                            itemVM.addItem(itemData: itemData, tag: inputEdit.selectionTagName, userID: userID)

                            inputHome.isPresentedEditItem.toggle()

                        case .update:

                            guard let passItemData = passItemData else { return }
                            guard let defaultDataID = passItemData.id else { return }
                            guard let editPrice = Int(inputEdit.editItemPrice) else { return }
                            guard let editSales = Int(inputEdit.editItemSales) else { return }
                            guard let editCost = Int(inputEdit.editItemCost) else { return }
                            guard let editInventory = Int(inputEdit.editItemInventory) else { return }

                            // NOTE: アイテムを更新
                            let updateItemData = (Item(createTime: passItemData.createTime,
                                                       tag: inputEdit.selectionTagName,
                                                       name: inputEdit.editItemName,
                                                       detail: inputEdit.editItemDetail != "" ? inputEdit.editItemDetail : "メモなし",
                                                       photo: inputEdit.photoURL != "" ? inputEdit.photoURL : "", // Todo: 写真取り込み実装後、変更
                                                       cost: editCost,
                                                       price: editPrice,
                                                       amount: 0,
                                                       sales: editSales,
                                                       inventory: editInventory,
                                                       totalAmount: passItemData.totalAmount,
                                                       totalInventory: passItemData.inventory < editInventory ?
                                                       passItemData.totalInventory + (editInventory - passItemData.inventory) :
                                                        passItemData.totalInventory - (passItemData.inventory - editInventory) ))

                            itemVM.updateItem(updateData: updateItemData, defaultDataID: defaultDataID)

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
    @StateObject var tagVM: TagViewModel
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

                        if passItem?.tag == tagVM.tags.last!.tagName {

                            ForEach(tagVM.tags) { tag in
                                if tag != tagVM.tags.first! {
                                    Text(tag.tagName).tag(tag.tagName)
                                }
                            }

                        } else {

                            ForEach(tagVM.tags) { tag in
                                if tag != tagVM.tags.first! && tag != tagVM.tags.last! {
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

                TextField("100", text: $inputEdit.editItemInventory)
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
                     tagVM: TagViewModel(),
                     inputHome: .constant(InputHome()),
                     inputImage: .constant(InputImage()),
                     userID: "AAAAAAAAAAAA",
                     itemIndex: 0,
                     passItemData: TestItem().testItem,
                     editItemStatus: .update
        )
    }
}
