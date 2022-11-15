//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

// NOTE: アイテムのソートタイプを管理します
enum SortType {
    case salesUp, salesDown, updateAtUp, createAtUp, start
}

// NOTE: アイテムのタググループ有無を管理します
enum TagGroup {
    case on // swiftlint:disable:this identifier_name
    case off
}

struct ManageView: View {

    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel

    @Binding var inputHome: InputHome
    @Binding var inputImage: InputImage

    struct InputManage {
        var tagGroup: TagGroup = .on
        var sortType: SortType = .start
        var isTagGroup: Bool = true
    }

    @State private var inputManage: InputManage = InputManage()

    var body: some View {

        NavigationView {
            ZStack {
                ScrollView(.vertical) {

                    VStack(alignment: .leading) {

                        // NOTE: タグ表示の「ON」「OFF」で表示を切り替えます
                        switch inputManage.isTagGroup {

                        case true:

                            if itemVM.items == [] {

                                EmptyItemView(inputHome: $inputHome, text: "アイテムが存在しません")

                            } else {
                                Spacer().frame(height: 60)
                                // タグの要素数の分リストを作成
                                ForEach(tagVM.tags) { tagRow in

                                    // firstには"ALL", lastには"タグ無し"
                                    if tagRow != tagVM.tags.first! && tagRow != tagVM.tags.last! {


                                        HStack {
                                            Text(tagRow.tagName)
                                                .foregroundColor(.white)
                                                .font(.title2.bold())
                                                .shadow(radius: 2, x: 4, y: 6)
                                                .padding(.vertical)
                                        }

                                        Spacer(minLength: 0)

                                        LinearGradient(gradient: Gradient(colors: [.gray, .clear]),
                                                                   startPoint: .leading, endPoint: .trailing)
                                            .frame(height: 1)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        if itemVM.items.contains(where: {$0.tag == tagRow.tagName}) {

                                            VStack {
                                                ForEach(itemVM.items) { item in

                                                    if item.tag == tagRow.tagName {
                                                        manageListRow(item: item)
                                                    }
                                                }
                                                Color.clear
                                                    .frame(height: 20)

                                                HStack {
                                                    Spacer()
                                                    Text("\(tagRow.tagName) ¥")
                                                        .font(.subheadline)
//                                                    Text(String(tagItemsSales))
                                                }
                                                .foregroundColor(.white.opacity(0.6))
                                                .padding(.trailing, 20)

                                            }

                                        } else {
                                            Text("タグに該当するアイテムはありません")
                                                .font(.subheadline)
                                                .foregroundColor(.white).opacity(0.6)
                                                .frame(height: 100)
                                        }
                                    }
                                } // ForEach tagVM.tags

                                // "未グループ"タグのついたアイテムが存在した場合
                                if itemVM.items.contains(where: {$0.tag == (tagVM.tags.last!.tagName)}) {
                                    Text(tagVM.tags.last!.tagName)
                                        .foregroundColor(.white)
                                        .font(.title2.bold())
                                        .shadow(radius: 2, x: 4, y: 6)
                                        .padding(.vertical)

                                    LinearGradient(gradient: Gradient(colors: [.gray, .clear]),
                                                               startPoint: .leading, endPoint: .trailing)
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        ForEach(itemVM.items) { item in

                                            if item.tag == "\(tagVM.tags.last!.tagName)" {
                                                manageListRow(item: item)
                                            }
                                        } // ForEach item
                                } // if
                            }

                        case false:

                            Spacer().frame(height: 70)

                            Text(tagVM.tags[0].tagName)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .shadow(radius: 2, x: 4, y: 6)
                                .padding(.vertical)

                            Spacer(minLength: 0)

                            LinearGradient(gradient: Gradient(colors: [.gray, .clear]),
                                                       startPoint: .leading, endPoint: .trailing)
                                .frame(height: 1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(itemVM.items) { item in

                                manageListRow(item: item)

                            } // case .groupOff
                        } // switch tagGroup
                    } // VStack
                    .padding(.leading)

                } // ScrollView
            } // ZStack
            .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                                       startPoint: .top, endPoint: .bottom))
            .navigationTitle("Manage")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.spring(response: 0.5), value: inputManage.isTagGroup)

            // sort Menu...
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {

                        Toggle(isOn: $inputManage.isTagGroup) {
                            HStack {
                                Image(systemName: inputManage.isTagGroup ? "tag.fill" : "tag.slash")
                                    .resizable()
                                    .foregroundColor(inputManage.isTagGroup ? .green : .gray)
                                Text("タググループ")
                            }
                        }

                        Menu("並び替え") {
                            Button {
                                inputManage.sortType = .salesUp
                                itemVM.items = itemVM.itemsSort(sort: inputManage.sortType, items: itemVM.items)
                            } label: {
                                if inputManage.sortType == .salesUp {
                                    Text("売り上げ(↑)　　 ✔︎")
                                } else {
                                    Text("売り上げ(↑)")
                                }
                            }
                            Button {
                                inputManage.sortType = .salesDown
                                itemVM.items = itemVM.itemsSort(sort: inputManage.sortType, items: itemVM.items)
                            } label: {
                                if inputManage.sortType == .salesDown {
                                    Text("売り上げ(↓)　　 ✔︎")
                                } else {
                                    Text("売り上げ(↓)")
                                }
                            }
                            Button {
                                inputManage.sortType = .updateAtUp
                                itemVM.items = itemVM.itemsSort(sort: inputManage.sortType, items: itemVM.items)
                            } label: {
                                if inputManage.sortType == .updateAtUp {
                                    Text("最終更新日　　　✔︎")
                                } else {
                                    Text("最終更新日")
                                }
                            }
                            Button {
                                inputManage.sortType = .createAtUp
                                itemVM.items = itemVM.itemsSort(sort: inputManage.sortType, items: itemVM.items)
                            } label: {
                                if inputManage.sortType == .createAtUp {
                                    Text("追加日　　　✔︎")
                                } else {
                                    Text("追加日")
                                }
                            }
                        } // 並び替えオプション

                    } label: {
                        Image(systemName: "list.bullet.indent")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
            }
            // System Side Menu ...
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            inputHome.isShowSystemSideMenu.toggle()
                        }
                        withAnimation(.easeIn(duration: 0.2)) {
                            inputHome.sideMenuBackGround.toggle()
                        }
                    } label: {
                        CircleIcon(photo: inputImage.iconImage, size: getSafeArea().top - 20)
                    }
                }
            }
        } // NavigationView
    } // body

    // Manage List Row...
    @ViewBuilder
    func manageListRow(item: Item) -> some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack(spacing: 20) {

                ShowItemPhoto(photo: item.photo, size: UIScreen.main.bounds.width / 5)

                VStack(alignment: .leading, spacing: 12) {

                    HStack {

                        Text("総計 ¥")
                            .font(.caption).opacity(0.7)
                            .foregroundColor(.white)

                        Text(item.sales != 0 ? String(item.sales) : "-")
                            .font(.subheadline.bold()).opacity(0.8)
                            .foregroundColor(.white)
                            .frame(width: 90, alignment: .leading)

                        HStack {
                            inputHome.switchElement.icon.font(.caption).opacity(0.5)

                            switch inputHome.switchElement {
                            case .stock:
                                Text(" \(item.inventory) 個")
                            case .price:
                                Text(item.price != 0 ? " \(item.price) 円" : " -")
                            }
                        }
                        .padding(5)
                        .font(.caption.bold()).opacity(0.7)
                        .foregroundColor(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.black.opacity(0.2))
                        }
                    }

                    IndicatorRow(value: item.sales,
                                 color: tagVM.fetchUsedColor(tagName: item.tag))

                    Text(item.name)
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.7))
                        .offset(y: 3)
                } // VStack
                Spacer()
            } // HStack
        } // VStack
        .onTapGesture {
            if let actionItemIndex = itemVM.items.firstIndex(of: item) {
                inputHome.actionItemIndex = actionItemIndex
                withAnimation(.easeIn(duration: 0.15)) {
                    inputHome.isShowItemDetail.toggle()
                }
            } else {
                print("インデックス取得失敗")
            }
        }
        .padding(.top)
    }

    private func switchIndicatorValue(item: Item, status: ElementStatus) -> Int {

        switch status {
        case .stock: return item.inventory
        case .price: return item.price
        }
    }

    private func tagGroupItemsSales(items: [Item]) -> Int {

        var itemsSales = 0

        for item in items {
            itemsSales += item.sales
        }

        return itemsSales
    }

} // View

struct ManageView_Previews: PreviewProvider {
    static var previews: some View {
        ManageView(itemVM: ItemViewModel(),
                   tagVM: TagViewModel(),
                   inputHome: .constant(InputHome()),
                   inputImage: .constant(InputImage()))
    }
}
