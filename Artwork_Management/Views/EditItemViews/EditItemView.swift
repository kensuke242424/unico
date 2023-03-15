//
//  UpdateItemView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/08.
//

import SwiftUI

struct InputEditItem {

    var captureImage: UIImage? = nil
    var selectionTagName: String = ""
    var photoURL: URL? = nil
    var photoPath: String? = nil
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
    var isShowItemImageSelectSheet: Bool = false
}

struct EditItemView: View {

    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel
    @Binding var inputHome: InputHome
    @Binding var inputImage: InputImage

    let itemIndex: Int
    let passItemData: Item?
    let editItemStatus: EditStatus

    var tagColor: UsedColor {
        let selectTag = tagVM.tags.filter({ $0.tagName == inputEdit.selectionTagName })
        if let selectTag = selectTag.first {
            return selectTag.tagColor
        } else {
            return .gray
        }
    }

    @State private var inputEdit: InputEditItem = InputEditItem()
    @State private var inputTag: InputTagSideMenu = InputTagSideMenu()

    var body: some View {

        NavigationView {

            ScrollView(showsIndicators: false) {

                ZStack {
                    Color.customDarkGray1
                        .ignoresSafeArea()
                        .overlay {
                            LinearGradient(gradient: Gradient(colors: [.clear, .customLightGray1]),
                                                       startPoint: .top, endPoint: .bottom)
                        }
                        .offset(y: 340)
                    VStack {
                        // ✅カスタムView 写真ゾーン
                        EditItemPhotoArea(showImageSheet: $inputEdit.isShowItemImageSelectSheet,
                                          photoImage: inputEdit.captureImage,
                                          photoURL: inputEdit.photoURL)

                        InputForms(itemVM: itemVM,
                                   tagVM: tagVM,
                                   inputEdit: $inputEdit,
                                   isOpenEditTagSideMenu: $inputHome.isOpenEditTagSideMenu,
                                   editItemStatus: editItemStatus,
                                   passItem: passItemData,
                                   tagColor: tagColor)

                    } // VStack(パーツ全体)
                } // ZStack(View全体)
                .animation(.easeIn(duration: 0.3), value: inputEdit.offset)

            } // ScrollView

            .sheet(isPresented: $inputEdit.isShowItemImageSelectSheet) {
                PHPickerView(captureImage: $inputEdit.captureImage,
                             isShowSheet: $inputEdit.isShowItemImageSelectSheet,
                             isShowError: $inputHome.showErrorFetchImage)
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
                    inputEdit.photoURL = passItemData.photoURL
                    inputEdit.photoPath = passItemData.photoPath
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
                            Task {
                                let uploadImage =  await itemVM.uploadImage(inputEdit.captureImage)
                                let itemData = Item(tag: inputEdit.selectionTagName,
                                                    tagColor: tagColor,
                                                    name: inputEdit.editItemName,
                                                    detail: inputEdit.editItemDetail != "" ? inputEdit.editItemDetail : "メモなし",
                                                    photoURL: uploadImage.url,
                                                    photoPath: uploadImage.filePath,
                                                    cost: 0,
                                                    price: Int(inputEdit.editItemPrice) ?? 0,
                                                    amount: 0,
                                                    sales: 0,
                                                    inventory: Int(inputEdit.editItemInventory) ??  0,
                                                    totalAmount: 0,
                                                    totalInventory: Int(inputEdit.editItemInventory) ?? 0)

                                // Firestoreにコーダブル保存
                                itemVM.addItem(itemData: itemData, tag: inputEdit.selectionTagName, teamID: teamVM.team!.id)

                                inputHome.isPresentedEditItem.toggle()
                            }

                        case .update:

                            Task {
                                guard let passItemData = passItemData else { return }
                                guard let defaultDataID = passItemData.id else { return }
                                let editInventory = Int(inputEdit.editItemInventory) ?? 0

                                // captureImageに新しい画像があれば、元の画像データを更新
                                if let captureImage = inputEdit.captureImage {
                                    await itemVM.deleteImage(path: inputEdit.photoPath)
                                    let newImageData =  await itemVM.uploadImage(captureImage)
                                    inputEdit.photoURL = newImageData.url
                                    inputEdit.photoPath = newImageData.filePath
                                }

                                // NOTE: アイテムを更新
                                let updateItemData = (Item(createTime: passItemData.createTime,
                                                           tag: inputEdit.selectionTagName,
                                                           tagColor: tagColor,
                                                           name: inputEdit.editItemName,
                                                           detail: inputEdit.editItemDetail != "" ? inputEdit.editItemDetail : "メモなし",
                                                           photoURL: inputEdit.photoURL,
                                                           photoPath: inputEdit.photoPath,
                                                           cost: Int(inputEdit.editItemCost) ?? 0,
                                                           price: Int(inputEdit.editItemPrice) ?? 0,
                                                           amount: 0,
                                                           sales: Int(inputEdit.editItemSales) ?? 0,
                                                           inventory: editInventory,
                                                           totalAmount: passItemData.totalAmount,
                                                           totalInventory: passItemData.inventory < editInventory ?
                                                           passItemData.totalInventory + (editInventory - passItemData.inventory) :
                                                            passItemData.totalInventory - (passItemData.inventory - editInventory) ))

                                itemVM.updateItem(updateData: updateItemData, defaultDataID: defaultDataID, teamID: teamVM.team!.id)

                                inputHome.isPresentedEditItem.toggle()
                            }

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
                    Picker("タグネーム", selection: $inputEdit.selectionTagName) {

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
        .padding(.horizontal, 40)
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
        EditItemView(teamVM: TeamViewModel(),
                     userVM: UserViewModel(),
                     itemVM: ItemViewModel(),
                     tagVM: TagViewModel(),
                     inputHome: .constant(InputHome()),
                     inputImage: .constant(InputImage()),
                     itemIndex: 0,
                     passItemData: TestItem().testItem.first!,
                     editItemStatus: .update
        )
    }
}
