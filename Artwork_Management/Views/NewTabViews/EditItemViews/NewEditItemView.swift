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
    static let name = EditStatus.Model(          title: "アイテム名", example: "")
    static let author = EditStatus.Model(        title: "作者"     , example: "")
    static let inventory = EditStatus.Model(     title: "在庫"     , example: "100")
    static let price = EditStatus.Model(         title: "価格"     , example: "1500")
    static let sales = EditStatus.Model(         title: "売上"     , example: "100000")
    static let totalAmount = EditStatus.Model(   title: "総売上"    , example: "")
    static let totalInventory = EditStatus.Model(title: "総売個数"  , example: "")
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
    
    let passItem: Item?
    
    var body: some View {
        
        GeometryReader {
            let size = $0.size
            VStack(spacing: 20) {
                
                EditTopBar()
                
                ScrollView(showsIndicators: false) {
                    /// 写真エリア
                    Rectangle()
                        .fill(.gray)
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
                        VStack(alignment: .leading, spacing: 40) {
                            
                            HStack {
                                Text("■ \(value.model.title)")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            VStack(alignment: .leading) {
                            
                                switch value {
                                case .name:
                                    TextField(value.model.example, text: $input.name)
                                        .focused($focused, equals: value)
                                case .author:
                                    TextField(value.model.example, text: $input.author)
                                        .focused($focused, equals: value)
                                case .inventory:
                                    TextField(value.model.example, text: $input.inventory)
                                        .focused($focused, equals: value)
                                case .price:
                                    TextField(value.model.example, text: $input.price)
                                        .focused($focused, equals: value)
                                case .sales:
                                    TextField(value.model.example, text: $input.sales)
                                        .focused($focused, equals: value)
                                case .totalAmount:
                                    TextField(value.model.example, text: $input.totalAmount)
                                        .focused($focused, equals: value)
                                case .totalInventory:
                                    TextField(value.model.example, text: $input.totalInventry)
                                        .focused($focused, equals: value)
                                }
                                
                                FocusedLineRow(select: focused == value ? true : false)
                            }
                            
                        }
                        .frame(width: size.width * 0.9, height: 100)
//                        .border(.red)
                    }
                }.padding(.bottom, 100)
            }
        }
        /// 少し下めにするのがちょうど良さそう
        .offset(y: getSafeArea().top)
        .navigationBarBackButtonHidden()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    @ViewBuilder
    func EditTopBar() -> some View {
        Text(passItem == nil ? "アイテム追加" : "アイテム編集")
            .font(.title2)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Button {
                    
                } label: {
                    Text(passItem == nil ? "追加" : "更新")
                }
                .padding(.trailing)
            }
            .overlay(alignment: .leading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .padding(.leading)
            }
            
    }
}

struct NewEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewEditItemView(teamVM: TeamViewModel(),
                        userVM: UserViewModel(),
                        itemVM: ItemViewModel(),
                        tagVM : TagViewModel(),
                        passItem: nil)
    }
}
