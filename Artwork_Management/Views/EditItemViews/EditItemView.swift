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

enum UsedColor: CaseIterable {

    case red
    case blue
    case yellow
    case green
    case gray

    var text: String {
        switch self {
        case .red:
            return "赤"
        case .blue:
            return "青"
        case .yellow:
            return "黄"
        case .green:
            return "緑"
        default:
            return "灰"
        }
    }
    var color: Color {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .yellow:
            return .yellow
        case .green:
            return .green
        default:
            return .gray
        }
    }
}

struct EditItemView: View {

    @StateObject var itemVM: ItemViewModel

    @Binding var isPresentedEditItem: Bool

    let itemIndex: Int
    let passItemData: Item?

    // NOTE: enum「Status」を用いて、「.create」と「.update」とでViewレイアウトを分岐します。
    let editItemStatus: Status

    // NOTE: ＠Stateの入力プロパティを構造体化
    struct InputEditItem {
        var passItemColor: Color = .red
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
    }
    @State private var input: InputEditItem = InputEditItem()

    @FocusState private var focusedField: Field?

    var body: some View {

        NavigationView {

            ScrollView(showsIndicators: false) {

                ZStack {
                    VStack {
                        // ✅カスタムView 写真ゾーン
                        SelectItemPhotoArea(selectTagColor: input.passItemColor)

                        // -------- 入力フォームここから ---------- //

                        VStack(spacing: 30) {

                            VStack(alignment: .leading) {
                                InputFormTitle(title: "■タグ設定", isNeed: true)
                                    .padding(.bottom)

                                HStack {
                                    Image(systemName: "tag.fill")
                                    // NOTE: メソッドで選択タグと紐づいたカラーを取り出す
                                        .foregroundColor(input.passItemColor)

                                    Picker("", selection: $input.selectionTagName) {

                                        ForEach(0 ..< itemVM.tags.count, id: \.self) { index in

                                            if let tagsRow = itemVM.tags[index] {
                                                Text(tagsRow.tagName).tag(tagsRow.tagName)
                                            }
                                        }
                                        Text("＋タグを追加").tag("＋タグを追加")
                                    } // Picker

                                    Spacer()

                                    Button {

                                        input.isOpenSideMenu.toggle()

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

                                TextField("1st Album「...」", text: $input.editItemName)
                                    .focused($focusedField, equals: .name)
                                    .autocapitalization(.none)
                                    .onTapGesture { focusedField = .name }
                                    .onSubmit { focusedField = .stock }

                                FocusedLineRow(select: focusedField == .name ? true : false)

                            } // ■アイテム名

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■在庫数", isNeed: false)
                                    .padding(.bottom)

                                TextField("100", text: $input.editItemInventry)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .stock)
                                    .onTapGesture { focusedField = .stock }
                                    .onSubmit { focusedField = .price }

                                FocusedLineRow(select: focusedField == .stock ? true : false)

                            } // ■在庫数

                            VStack(alignment: .leading) {

                                InputFormTitle(title: "■価格(税込)", isNeed: false)
                                    .padding(.bottom)

                                TextField("2000", text: $input.editItemPrice)
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

                                    TextField("2000", text: $input.editItemSales)
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

                                TextEditor(text: $input.editItemDetail)
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 200)
                                    .shadow(radius: 3, x: 0, y: 0)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .detail)
                                    .onTapGesture { focusedField = .detail }
                                    .overlay(alignment: .topLeading) {
                                        if focusedField != .detail {
                                            if input.editItemDetail.isEmpty {
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

                    if input.isOpenSideMenu {

                        SideMenuEditTagView(
                            itemVM: itemVM,
                            isOpenSideMenu: $input.isOpenSideMenu,
                            geometryMinY: $input.geometryMinY,
                            selectionTagName: $input.selectionTagName,
                            selectionTagColor: $input.selectionTagColor,
                            itemTagName: input.selectionTagName,
                            itemTagColor: input.selectionTagColor,
                            editItemStatus: editItemStatus,
                            // Warning_TextSimbol: "＋タグを追加"
                            tagSideMenuStatus: input.selectionTagName == "＋タグを追加" ? .create : .update)

                    } // if isOpenSideMenu

                } // ZStack(View全体)
                // アイテム詳細
                .offset(y: focusedField == .detail && -550.0 <= input.geometryMinY ? input.offset - 300 : 0)
                .animation(.easeIn(duration: 0.3), value: input.offset)

                // NOTE: スクロールView全体を.backgroundからgeometry取得します。
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: OffsetPreferenceKey.self,
                                        value: geometry.frame(in: .named("scrollSpace")).minY)
                            .onChange(of: geometry.frame(in: .named("scrollFrame_Space")).minY) { newValue in

                                withAnimation(.easeIn(duration: 0.1)) {
                                    self.input.geometryMinY = newValue
                                }
                            } // onChange
                    } // Geometry
                ) // .background(geometry)

            } // ScrollView
            .coordinateSpace(name: "scrollFrame_Space")

            .onTapGesture { focusedField = nil }

            .onChange(of: input.selectionTagName) { selection in

                // NOTE: 選択されたタグネームと紐づいたタグカラーを取り出し、selectionTagColorに格納します。
                let searchedTagColor = itemVM.searchSelectTagColor(selectTagName: selection,
                                                                   tags: itemVM.tags)
                withAnimation(.easeIn(duration: 0.25)) {
                    input.passItemColor = searchedTagColor
                }

                // NOTE: タグ選択で「+タグを追加」が選択された時、新規タグ追加Viewを表示します。
                // Warning_TextSimbol: "＋タグを追加"
                if selection == "＋タグを追加" {
                    self.input.isOpenSideMenu.toggle()
                    print("サイドメニュー: \(input.isOpenSideMenu)")
                }
            } // onChange (selectionTagName)

            .onChange(of: input.editItemName) { newValue in

                withAnimation(.easeIn(duration: 0.2)) {
                    if newValue.isEmpty {
                        self.input.disableButton = true
                    } else {
                        self.input.disableButton = false
                    }
                }
            } // onChange(ボタンdisable分岐)

            // NOTE: タグ追加サイドメニュー表示後、新規タグが追加されず、サイドメニューが閉じられた時(タグ選択が「＋タグ選択」のままの状態)
            //       タグピッカーの選択をアイテムが保有するタグに戻します。
            .onChange(of: input.isOpenSideMenu) { isOpen in

                if isOpen == false {
                    // Warning_TextSimbol: "＋タグを追加"
                    if input.selectionTagName == "＋タグを追加" {

                        switch editItemStatus {

                        case .create:
                            if let defaultTag = itemVM.tags.first {
                                self.input.selectionTagName = defaultTag.tagName
                            }

                        case .update:
                            if let editItemData = passItemData {
                                input.selectionTagName = editItemData.tag
                            }
                        } // switch

                    } // if selectionTagName == "＋タグを追加"
                } // if isOpen == false
            } // onChange(サイドメニューが綴じられた後の選択タグ監視)

            // NOTE: updateitemView呼び出し時に、親Viewから受け取ったアイテム情報を各入力欄に格納します。
            .onAppear {

                print("EditItemView_onAppear_実行")

                print("アイテム編集ステータス: \(editItemStatus)")

                // NOTE: 新規アイテム登録遷移の場合、passItemDataにはnilが代入されている
                if let passItemData = passItemData {

                    self.input.passItemColor = itemVM.searchSelectTagColor(
                        selectTagName: passItemData.tag, tags: itemVM.tags)

                    self.input.selectionTagName = passItemData.tag
                    self.input.editItemName = passItemData.name
                    self.input.editItemInventry = String(passItemData.inventory)
                    self.input.editItemPrice = String(passItemData.price)
                    self.input.editItemSales = String(passItemData.sales)
                    self.input.editItemDetail = passItemData.detail

                } else {
                    guard let defaultTag = itemVM.tags.first else { return }
                    self.input.selectionTagName = defaultTag.tagName
                    self.input.passItemColor = defaultTag.tagColor
                }

            } // onAppear

            .navigationTitle(editItemStatus == .create ? "新規アイテム" : "アイテム編集")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button {

                        //                        // NOTE: Firestoreへのデータ保存を見越して、Color型はString型に変換しておきます。
                        //                        let castTagColorString = itemVM.castColorIntoString(color: input.selectionTagColor)

                        switch editItemStatus {

                        case .create:

                            // NOTE: テストデータに新規アイテムを保存
                            itemVM.items.append(Item(tag: input.selectionTagName,
                                                     tagColor: input.selectionTagColor.text,
                                                     name: input.editItemName,
                                                     detail: input.editItemDetail != "" ? input.editItemDetail : "none.",
                                                     photo: "", // Todo: 写真取り込み実装後、変更
                                                     price: Int(input.editItemPrice) ?? 0,
                                                     sales: 0,
                                                     inventory: Int(input.editItemInventry) ?? 0,
                                                     createTime: Date(), // Todo: Timestamp実装後、変更
                                                     updateTime: Date())) // Todo: Timestamp実装後、変更

                            if let appendNewItem = itemVM.items.last {
                                print("新規追加されたアイテム: \(appendNewItem)")
                            }

                        case .update:
                            // NOTE: テストデータに情報の変更を保存
                            let updateItemSource = Item(tag: input.selectionTagName,
                                                        tagColor: input.selectionTagColor.text,
                                                        name: input.editItemName,
                                                        detail: input.editItemDetail != "" ? input.editItemDetail : "none.",
                                                        photo: "", // Todo: 写真取り込み実装後、変更
                                                        price: Int(input.editItemPrice) ?? 0,
                                                        sales: Int(input.editItemSales) ?? 0,
                                                        inventory: Int(input.editItemInventry) ?? 0,
                                                        createTime: Date(), // Todo: Timestamp実装後、変更
                                                        updateTime: Date()) // Todo: Timestamp実装後、変更

                            // NOTE: アイテムを更新
                            itemVM.items[itemIndex] = updateItemSource
                            print("更新されたアイテム: \(itemVM.items[itemIndex])")

                        } // switch editItemStatus

                        // シートを閉じる
                        self.isPresentedEditItem.toggle()

                    } label: {
                        Text(editItemStatus == .create ? "追加する" : "更新する")
                    }
                    .disabled(input.disableButton)
                }
            } // toolbar(アイテム追加ボタン)

        } // NavigationView
    } // body
} // View

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
                     passItemData:
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
