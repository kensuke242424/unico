//
//  NewEditItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/17.
//

import SwiftUI

enum InputFormsStatus: CaseIterable {
    case name, author ,inventory , price, sales ,totalAmount ,totalInventory
    
    struct Model {
        let title: String
        let example: String
    }
    
    var model: Model {
        switch self {
        case .name          : return .name
        case .author        : return .author
        case .inventory     : return .inventory
        case .price         : return .price
        case .sales         : return .sales
        case .totalAmount   : return .totalAmount
        case .totalInventory: return .totalInventory
        }
    }
}

extension InputFormsStatus.Model {
    static let name = InputFormsStatus.Model(          title: "アイテム名", example: "unico")
    static let author = InputFormsStatus.Model(        title: "製作者"   , example: "ユニコ 太郎")
    static let inventory = InputFormsStatus.Model(     title: "在庫"     , example: "100")
    static let price = InputFormsStatus.Model(         title: "価格"     , example: "1500")
    static let sales = InputFormsStatus.Model(         title: "総売上"    , example: "100000")
    static let totalAmount = InputFormsStatus.Model(   title: "総売個数"  , example: "150")
    static let totalInventory = InputFormsStatus.Model(title: "総仕入れ"  , example: "300")
}

struct InputEditItem {

    /// アイテムの入力ステータス群
    var captureImage    : UIImage? = nil
    var selectionTagName: String = ""
    var name            : String = ""
    var author          : String = ""
    var photoURL        : URL? = nil
    var photoPath       : String? = nil
    var detail          : String = ""
    var inventory       : String = ""
    var cost            : String = ""
    var price           : String = ""
    var sales           : String = ""
    var totalAmount     : String = ""
    var totalInventry   : String = ""
    
    /// view表示Presentを管理する
    var showPicker  : Bool = false
    var showProgress: Bool = false
}

struct NewEditItemView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tagVM : TagViewModel
    @StateObject var itemVM      : ItemViewModel
    
    @State private var input: InputEditItem = InputEditItem()
    
    @FocusState var focused: InputFormsStatus?
    // アイテム詳細テキストフィールド専用のフォーカス制御
    @FocusState var detailFocused: Bool?
    
    let passItem: RootItem?
    
    var body: some View {
        
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 20) {
                
                EditTopNavigateBar(width: size.width - 15)
                
                ScrollView(showsIndicators: false) {
                    /// 📷選択写真を表示するエリア📷
                    ZStack {
                        SelectItemPhotoBackground(photoImage: input.captureImage,
                                                  photoURL: passItem?.photoURL,
                                                  height: 250)
                        .onTapGesture { focused = nil; detailFocused = nil }
                        
                        if let captureImage = input.captureImage {
                            NewItemUIImage(image: captureImage,
                                           width: size.width / 2 - 15,
                                           height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture { input.showPicker.toggle() }
                        } else if let passItemImageURL = input.photoURL {
                            NewItemSDWebImage(imageURL: passItemImageURL,
                                              width: size.width / 2 - 15,
                                              height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture { input.showPicker.toggle() }
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.gradient)
                                .frame(width: abs(size.width / 2 - 15), height: 220)
                                .onTapGesture { input.showPicker.toggle() }
                            VStack(spacing: 20) {
                                Image(systemName: "cube.transparent.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundColor(.white)
                                
                                Text("写真を選択")
                                    .fontWeight(.semibold)
                                    .tracking(5)
                                    .foregroundColor(.white)
                            }
                        }
                    } // ZStack(選択画像エリア)
                    
                    /// 入力欄の各項目
                    ForEach(InputFormsStatus.allCases, id: \.self) { value in
                        InputForm(size, value)
                    } // ForEach
                    
                    // 複数行を書けるアイテム詳細テキストフィールド
                    // ここの入力欄だけは少々仕様が異なるため、ForEach外で実装
                    HStack {
                        Text("■ アイテムの詳細")
                            .fontWeight(.semibold)
                            .tracking(1)
                            .opacity(0.5)
                        /// 空白部分タップでフォーカスをnilにするためのほぼ透明の範囲View
                        Color.gray
                            .opacity(0.001)
                    }
                    .frame(width: size.width * 0.8, alignment: .leading)
                    .onTapGesture { focused = nil; detailFocused = nil }
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    
                    TextField("アイテムについてメモを残しましょう。",
                              text: $input.detail,
                              axis: .vertical)
                    .font(.subheadline)
                    .opacity(0.7)
                    .kerning(0.5)
                    .lineSpacing(4)
                    .focused($detailFocused, equals: true)
                    .textInputAutocapitalization(.never)
                    .frame(width: size.width * 0.82)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray)
                            .opacity(0.4)
                    }
                    
                    Color.gray
                        .opacity(0.001)
                        .frame(width: size.width, height: size.height / 2)
                        .onTapGesture { focused = nil; detailFocused = nil }
                } // ScrollView
            } // VStack
        } // Geometry
        /// 少し下めにするのがちょうど良さそう
        .offset(y: getSafeArea().top)
        .navigationBarBackButtonHidden()
        .background {
            GeometryReader {
                let size = $0.size
                Image("background_2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .opacity(0.1)
                    .onTapGesture { focused = nil }
            }
            .ignoresSafeArea()
        }
        .overlay {
            if input.showProgress {
                SavingProgressView()
            }
        }
        .sheet(isPresented: $input.showPicker) {
            PHPickerView(captureImage: $input.captureImage,
                         isShowSheet: $input.showPicker)
        }
        /// passItemにアイテムが存在した場合、各入力値にアイテムデータを入れる
        .onAppear {
            if let passItem {
                input.photoURL      = passItem.photoURL
                input.photoPath     = passItem.photoPath
                input.name          = passItem.name != "No Name" ? passItem.name : ""
                input.author        = passItem.author
                input.inventory     = String(passItem.inventory)
                input.cost          = passItem.cost != 0 ? String(passItem.cost) : ""
                input.price         = passItem.price != 0 ? String(passItem.price) : ""
                input.sales         = passItem.sales != 0 ? String(passItem.sales) : ""
                input.detail        = passItem.detail != "メモなし" ? passItem.detail : ""
                input.totalAmount   = passItem.totalAmount != 0 ? String(passItem.totalAmount) : ""
                input.totalInventry = passItem.totalInventory != 0 ? String(passItem.totalInventory) : ""
            }
        }
    }
    
    @ViewBuilder
    func EditTopNavigateBar(width: CGFloat) -> some View {
        Text(passItem == nil ? "新規アイテム" : "アイテム編集")
            .font(.title3)
            .fontWeight(.semibold)
            .tracking(2)
            .frame(maxWidth: .infinity)
            /// ✅ 追加 or 更新ボタン
            .overlay(alignment: .trailing) {
                Button {
                    /// passItemにデータがある -> update Item
                    /// passItemにデータがない -> add item
                    if let passItem {

                        Task {
                            guard let defaultDataID = passItem.id else { return }
                            let editInventory = Int(input.inventory) ?? 0

                            // captureImageに新しい画像があれば、元の画像データを更新
                            if let captureImage = input.captureImage {
                                input.showProgress = true
                                itemVM.deleteImage(path: input.photoPath)
                                let resizedImage = itemVM.resizeUIImage(image: captureImage,
                                                                        width: width)
                                let newImageData =  await itemVM.uploadImage(resizedImage)
                                input.photoURL = newImageData.url
                                input.photoPath = newImageData.filePath
                            }

                            // NOTE: アイテムを更新
                            let updateItemData = (RootItem(createTime: passItem.createTime,
                                                           tag        : input.selectionTagName,
                                                           teamID: teamVM.team!.id,
                                                           name       : input.name,
                                                           author     : input.author,
                                                           detail     : input.detail != "" ? input.detail : "メモなし",
                                                           photoURL   : input.photoURL,
                                                           photoPath  : input.photoPath,
                                                           cost       : Int( input.cost) ?? 0,
                                                           price      : Int(input.price) ?? 0,
                                                           amount     : 0,
                                                           sales      : Int(input.sales) ?? 0,
                                                           inventory  : editInventory,
                                                           totalAmount: passItem.totalAmount,
                                                           totalInventory: passItem.inventory < editInventory ?
                                                           passItem.totalInventory + (editInventory - passItem.inventory) :
                                                            passItem.totalInventory - (passItem.inventory - editInventory) ))

                            itemVM.updateItem(updateData: updateItemData, defaultDataID: defaultDataID, teamID: teamVM.team!.id)
                            input.showProgress = false
                            dismiss()
                        } // Task(update Item)
                        
                    } else {
                        
                        Task {
                            
                            // captureImageに新しい画像があれば、元の画像データを更新
                            if let captureImage = input.captureImage {
                                input.showProgress = true
                                itemVM.deleteImage(path: input.photoPath)
                                let resizedImage = itemVM.resizeUIImage(image: captureImage, width: width)
                                let newImageData =  await itemVM.uploadImage(resizedImage)
                                input.photoURL = newImageData.url
                                input.photoPath = newImageData.filePath
                            }
                            
                            let itemData = RootItem(tag           : input.selectionTagName,
                                                    teamID: teamVM.team!.id,
                                                    name          : input.name,
                                                    author        : input.author,
                                                    detail        : input.detail != "" ? input.detail : "メモなし",
                                                    photoURL      : input.photoURL,
                                                    photoPath     : input.photoPath,
                                                    cost          : 0,
                                                    price         : Int(input.price) ?? 0,
                                                    amount        : 0,
                                                    sales         : 0,
                                                    inventory     : Int(input.inventory) ??  0,
                                                    totalAmount   : 0,
                                                    totalInventory: Int(input.inventory) ?? 0)
                            
                            // Firestoreにコーダブル保存
                            itemVM.addItem(itemData: itemData, tag: input.selectionTagName, teamID: teamVM.team!.id)
                            
                            input.showProgress = false
                            dismiss()
                        } // Task(add Item)
                    } // if let passItem
                        
                } label: {
                    Text(passItem == nil ? "追加" : "更新")
                        .tracking(1)
                        .fontWeight(.semibold)
                }
                .padding(.trailing)
            }
            .overlay(alignment: .leading) {
                Button {
                    dismiss()
                } label: {
                    Label("キャンセル", systemImage: "chevron.left")
                        .font(.subheadline)
                }
                .padding(.leading)
            }
    }
    
    @ViewBuilder
    func InputForm(_ size: CGSize,_ value: InputFormsStatus) -> some View {
        
        /// アイテム追加の場合は以下の項目だけを表示する
        if !(passItem == nil    &&
            value != .name      &&
            value != .author    &&
            value != .inventory &&
            value != .price
        ) {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Text("■ \(value.model.title)")
                        .fontWeight(.semibold)
                        .tracking(1)
                        .opacity(0.5)
                    /// 空白部分タップでフォーカスをnilにするためのほぼ透明の範囲View
                    Color.gray
                        .opacity(0.001)
                }
                .frame(width: size.width * 0.8, alignment: .leading)
                .onTapGesture { focused = nil; detailFocused = nil }
                
                VStack {
                
                    switch value {
                    case .name:
                        TextField(value.model.example, text: $input.name)
                            .focused($focused, equals: value)
                            .textInputAutocapitalization(.never)
                            .tracking(1)
                    case .author:
                        TextField(value.model.example, text: $input.author)
                            .focused($focused, equals: value)
                            .textInputAutocapitalization(.never)
                            .tracking(1)
                    case .inventory:
                        TextField(value.model.example, text: $input.inventory)
                            .focused($focused, equals: value)
                            .keyboardType(.numberPad)
                            .tracking(1)
                    case .price:
                        TextField(value.model.example, text: $input.price)
                            .focused($focused, equals: value)
                            .keyboardType(.numberPad)
                            .tracking(1)
                    case .sales:
                        TextField(value.model.example, text: $input.sales)
                            .focused($focused, equals: value)
                            .keyboardType(.numberPad)
                            .tracking(1)
                    case .totalAmount:
                        TextField(value.model.example, text: $input.totalAmount)
                            .focused($focused, equals: value)
                            .keyboardType(.numberPad)
                            .tracking(1)
                    case .totalInventory:
                        TextField(value.model.example, text: $input.totalInventry)
                            .focused($focused, equals: value)
                            .keyboardType(.numberPad)
                            .tracking(1)
                    }
                    
                    FocusedLineRow(select: focused == value ? true : false,
                                   width : size.width * 0.8)
                }
            } // VStack
            .frame(width: size.width * 0.8, height: 90)
            .onChange(of: focused) { newValue in
                if newValue == .inventory {
                    if input.inventory == "0" {
                        input.inventory = ""
                    }
                }
            }
        }
    }
}

struct NewEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewEditItemView(itemVM: ItemViewModel(), passItem: testItem.first)
    }
}
