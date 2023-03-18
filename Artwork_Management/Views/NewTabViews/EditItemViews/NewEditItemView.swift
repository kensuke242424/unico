//
//  NewEditItemView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/17.
//

import SwiftUI

enum EditStatus: CaseIterable {
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

extension EditStatus.Model {
    static let name = EditStatus.Model(          title: "アイテム名", example: "unico")
    static let author = EditStatus.Model(        title: "製作者"   , example: "ユニコ 太郎")
    static let inventory = EditStatus.Model(     title: "在庫"     , example: "100")
    static let price = EditStatus.Model(         title: "価格"     , example: "1500")
    static let sales = EditStatus.Model(         title: "売上"     , example: "100000")
    static let totalAmount = EditStatus.Model(   title: "総売上"    , example: "150")
    static let totalInventory = EditStatus.Model(title: "総売個数"  , example: "300")
}

struct InputEditItem {

    var captureImage: UIImage? = nil
    var selectionTagName: String = ""
    var photoURL: URL? = nil
    var photoPath: String? = nil
    var name: String = ""
    var author: String = ""
    var inventory: String = ""
    var cost: String = ""
    var price: String = ""
    var sales: String = ""
    var detail: String = ""
    var totalAmount: String = ""
    var totalInventry: String = ""
    var disableButton: Bool = true
    var offset: CGFloat = 0
    var isCheckedFocuseDetail: Bool = false
    var isShowItemImageSelectSheet: Bool = false
}

struct NewEditItemView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var teamVM: TeamViewModel
    @StateObject var userVM: UserViewModel
    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM : TagViewModel
    
    @State private var input: InputEditItem = InputEditItem()
    
    @FocusState var focused: EditStatus?
    // アイテム詳細テキストフィールド専用のフォーカス制御
    @FocusState var detailFocused: Bool?
    
    let passItem: Item?
    
    var body: some View {
        
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 20) {
                
                EditTopNavigateBar()
                
                ScrollView(showsIndicators: false) {
                    /// 写真エリア
                    Rectangle()
                        .fill(.gray.gradient)
                        .frame(height: 250)
                        .opacity(0.1)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.gradient)
                                .frame(width: size.width / 2, height: 220)
                        }
                        .overlay {
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
                    /// 入力欄エリア
                    ForEach(EditStatus.allCases, id: \.self) { value in
                        InputForm(size, value)
                    } // ForEach
                    
                    // 複数行を書けるアイテム詳細テキストフィールド
                    // ここの入力欄だけは少々仕様が異なるため、ForEach外で実装
                    HStack {
                        Text("■ アイテムの詳細")
                            .fontWeight(.semibold)
                            .tracking(1)
                        /// 空白部分タップでフォーカスをnilにするためのほぼ透明の範囲View
                        Color.gray
                            .opacity(0.001)
                    }
                    .frame(width: size.width * 0.8, alignment: .leading)
                    .onTapGesture {
                        focused       = nil
                        detailFocused = nil
                    }
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
                    .frame(width: size.width * 0.75)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray)
                            .opacity(0.4)
                    }
                    
                    Color.gray
                        .opacity(0.001)
                        .frame(width: size.width, height: size.height / 2)
                        .onTapGesture {
                            focused       = nil
                            detailFocused = nil
                        }
                } // ScrollView
            } // VStack
        } // Geometry
        /// 少し下めにするのがちょうど良さそう
        .offset(y: getSafeArea().top)
        .navigationBarBackButtonHidden()
        .background {
            GeometryReader {
                let size = $0.size
                Image("background_1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .opacity(0.1)
                    .onTapGesture { focused = nil }
            }
            .ignoresSafeArea()
        }
    }
    @ViewBuilder
    func EditTopNavigateBar() -> some View {
        Text(passItem == nil ? "アイテム追加" : "アイテム編集")
            .font(.title3)
            .fontWeight(.semibold)
            .tracking(2)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Button {
                    //TODO: アイテム情報の更新 or 追加
                    dismiss()
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
    func InputForm(_ size: CGSize,_ value: EditStatus) -> some View {
        
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
                    /// 空白部分タップでフォーカスをnilにするためのほぼ透明の範囲View
                    Color.gray
                        .opacity(0.001)
                }
                .frame(width: size.width * 0.8, alignment: .leading)
                .onTapGesture {
                    focused       = nil
                    detailFocused = nil
                }
                
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
                    
                    FocusedLineRow(select: focused == value ? true : false)
                }
            } // VStack
            .frame(width: size.width * 0.8, height: 90)
        }
        
    }
}

struct NewEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewEditItemView(teamVM: TeamViewModel(),
                        userVM: UserViewModel(),
                        itemVM: ItemViewModel(),
                        tagVM : TagViewModel(),
                        passItem: testItem.first)
    }
}
