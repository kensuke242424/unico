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
    var selectionTag    : Tag?
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
    var showPhotoPicker: Bool = false
    var showTagEdit    : Bool = false
    var showProgress   : Bool = false
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
    
    let passItem: Item?
    
    var body: some View {
        
        GeometryReader {
            let size = $0.size
            /// 親View側のスクロールViewを参照したsizeを元にしたカードのサイズ
            let cardWidth : CGFloat = size.width / 2 - 15
            let cardHeight: CGFloat = 220
            
            VStack(spacing: 20) {
                
                EditTopNavigateBar(width: cardWidth)
                
                ScrollView(showsIndicators: false) {
                    /// 📷選択写真を表示するエリア📷
                    ZStack {
                        SelectItemPhotoBackground(photoImage: input.captureImage,
                                                  photoURL: passItem?.photoURL,
                                                  height: 250)
                        
                        if let captureImage = input.captureImage {
                            NewItemUIImage(image: captureImage,
                                           width: cardWidth,
                                           height: cardHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture {
                                input.showPhotoPicker.toggle()
                                focused = nil; detailFocused = nil
                            }
                        } else if let passItemImageURL = input.photoURL {
                            SDWebImageView(imageURL: passItemImageURL,
                                              width: cardWidth,
                                              height: cardHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture {
                                input.showPhotoPicker.toggle()
                                focused = nil; detailFocused = nil
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.gradient)
                                .frame(width: abs(cardWidth), height: cardHeight)
                                .onTapGesture {
                                    input.showPhotoPicker.toggle()
                                    focused = nil; detailFocused = nil
                                }
                                
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
                            .onTapGesture {
                                input.showPhotoPicker.toggle()
                                focused = nil; detailFocused = nil
                            }
                        }
                    } // ZStack(選択画像エリア)
                    
                    HStack {
                        Text("\(Image(systemName: "tag.fill")) タグ")
                            .fontWeight(.semibold)
                            .tracking(1)
                            .opacity(0.5)
                            .padding(.trailing, 50)

                        Button {
                            // タグ追加処理
                            input.selectionTag = nil
                            withAnimation(.easeInOut(duration: 0.3)) { input.showTagEdit = true }
                        } label: {
                            Label("タグ追加", systemImage: "plus.app.fill")
                        }
                        .font(.footnote)
                    }
                    .frame(width: size.width * 0.8, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    HStack {
                        Picker("タグを選択", selection: $input.selectionTagName) {
                            ForEach(tagVM.tags.filter({ $0.tagName != "全て" }))
                            { tag in
                                Text(tag.tagName)
                                    .tag(tag.tagName)
                            }
                        }
                        .padding(.trailing)
                        .lineLimit(1)
                        .overlay(alignment: .trailing) {
                            if input.selectionTagName != "未グループ" {
                                Button {
                                    /// 現在Pickerで選ばれているタグ名を用いて、tagVMから編集対象のTagを取り出す
                                    input.selectionTag = tagVM.tags.first(where: { $0.tagName == input.selectionTagName })
                                    withAnimation(.easeInOut(duration: 0.3)) { input.showTagEdit = true }
                                } label: {
                                    Image(systemName: "pencil.line")
                                        .foregroundColor(.orange)
                                }
                                .offset(x: 20)
                            }
                        }
                    }
                    .frame(width: size.width * 0.8, alignment: .leading)
                    
                    FocusedLineRow(select: false,
                                   width : size.width * 0.8)
                    .frame(width: size.width * 0.8)
                    
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
        .overlay {
            if input.showTagEdit {
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
                EditTagView(passTag: $input.selectionTag, show: $input.showTagEdit)
                    .transition(AnyTransition.opacity.combined(with: .offset(y: 50)))
            }
        }
        .background {
            GeometryReader {
                let size = $0.size
                SDWebImageView(imageURL : teamVM.team?.backgroundURL,
                               width : size.width,
                               height: size.height)
                    .opacity(0.1)
                    .onTapGesture { focused = nil }
            }
            .ignoresSafeArea()
        }
        .overlay {
            if input.showProgress {
                SavingProgressView()
                    .transition(AnyTransition.opacity.combined(with: .offset(y: 20)))
            }
        }
        .sheet(isPresented: $input.showPhotoPicker) {
            PHPickerView(captureImage: $input.captureImage,
                         isShowSheet: $input.showPhotoPicker)
        }
        /// NOTE: 親Viewから渡されたアイテムのタグをもとにTagデータを取り出し、Pickerの$String値に使う
        .onChange(of: input.selectionTag) { newTag in
            guard let newTagName = newTag?.tagName else { return }
            input.selectionTagName = newTagName
        }
        /// passItemにアイテムが存在した場合、各入力値にアイテムデータを入れる
        .onAppear {
            if let passItem {
                input.selectionTag     = tagVM.tags.first(where: { $0.tagName == passItem.tag })
                input.photoURL         = passItem.photoURL
                input.photoPath        = passItem.photoPath
                input.name             = passItem.name != "No Name" ? passItem.name : ""
                input.author           = passItem.author
                input.inventory        = String(passItem.inventory)
                input.cost             = passItem.cost != 0 ? String(passItem.cost) : ""
                input.price            = passItem.price != 0 ? String(passItem.price) : ""
                input.sales            = passItem.sales != 0 ? String(passItem.sales) : ""
                input.detail           = passItem.detail != "メモなし" ? passItem.detail : ""
                input.totalAmount      = passItem.totalAmount != 0 ? String(passItem.totalAmount) : ""
                input.totalInventry    = passItem.totalInventory != 0 ? String(passItem.totalInventory) : ""
            } else {
                let filterTags = tagVM.tags.filter({ $0.tagName != "全て" })
                input.selectionTag = filterTags.first
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
                            guard let teamID = teamVM.team?.id else { return }
                            let editInventory = Int(input.inventory) ?? 0

                            // captureImageに新しい画像があれば、元の画像データを更新
                            if let captureImage = input.captureImage {
                                withAnimation(.easeIn(duration: 0.1)) { input.showProgress = true }
                                itemVM.deleteImage(path: input.photoPath)
                                let resizedImage = itemVM.resizeUIImage(image: captureImage,
                                                                        width: width * 2)
                                let newImageData =  await itemVM.uploadItemImage(resizedImage, teamID)
                                input.photoURL = newImageData.url
                                input.photoPath = newImageData.filePath
                            }

                            // NOTE: アイテムを更新
                            let updateItemData = (Item(createTime : passItem.createTime,
                                                       updateTime : nil,
                                                       tag        : input.selectionTagName,
                                                       teamID     : teamVM.team!.id,
                                                       name       : input.name,
                                                       author     : input.author,
                                                       detail     : input.detail != "" ? input.detail : "メモなし",
                                                       photoURL   : input.photoURL,
                                                       photoPath  : input.photoPath,
                                                       favorite   : false,
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
                            withAnimation(.easeIn(duration: 0.1)) { input.showProgress = false }
                            dismiss()
                        } // Task(update Item)
                        
                    } else {
                        
                        Task {
                            guard let teamID = teamVM.team?.id else { return }
                            
                            // captureImageに新しい画像があれば、元の画像データを更新
                            if let captureImage = input.captureImage {
                                withAnimation(.easeIn(duration: 0.1)) { input.showProgress = true }
                                itemVM.deleteImage(path: input.photoPath)
                                let resizedImage = itemVM.resizeUIImage(image: captureImage, width: width)
                                let newImageData =  await itemVM.uploadItemImage(resizedImage, teamID)
                                input.photoURL = newImageData.url
                                input.photoPath = newImageData.filePath
                            }
                            
                            let itemData = Item(tag           : input.selectionTagName,
                                                    teamID        : teamVM.team!.id,
                                                    name          : input.name,
                                                    author        : input.author,
                                                    detail        : input.detail != "" ? input.detail : "メモなし",
                                                    photoURL      : input.photoURL,
                                                    photoPath     : input.photoPath,
                                                    favorite      : false,
                                                    cost          : 0,
                                                    price         : Int(input.price) ?? 0,
                                                    amount        : 0,
                                                    sales         : 0,
                                                    inventory     : Int(input.inventory) ??  0,
                                                    totalAmount   : 0,
                                                    totalInventory: Int(input.inventory) ?? 0)
                            
                            // Firestoreにコーダブル保存
                            itemVM.addItem(itemData: itemData,
                                           tag: input.selectionTag?.tagName ?? "未グループ",
                                           teamID: teamVM.team!.id)
                            
                            withAnimation(.easeIn(duration: 0.1)) { input.showProgress = false }
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
                    Label("戻る", systemImage: "chevron.left")
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
            .environmentObject(TagViewModel())
    }
}
