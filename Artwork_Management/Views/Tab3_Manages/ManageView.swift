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

    // NOTE: 新規アイテム追加Viewの発現を管理します
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

                            if tagVM.tags.count < 3 {

                                VStack {
                                    Text("アイテムが存在しません")
                                        .font(.subheadline)
                                        .foregroundColor(.white).opacity(0.6)
                                        .frame(height: 200)
                                }
                                .frame(maxWidth: .infinity)

                            } else {
                                // タグの要素数の分リストを作成
                                ForEach(tagVM.tags) { tagRow in

                                    // firstには"ALL", lastには"タグ無し"
                                    if tagRow != tagVM.tags.first! && tagRow != tagVM.tags.last! {

                                        HStack {
                                            Text(tagRow.tagName)
                                                .foregroundColor(.white)
                                                .font(.title.bold())
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

    @ViewBuilder
    func manageListRow(item: Item) -> some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack(spacing: 20) {

                ShowItemPhoto(photo: item.photo, size: UIScreen.main.bounds.width / 5)
                    .onTapGesture {
                        print("画像タップ")
                    }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 40) {
                        Text("¥ \(item.sales)")
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .font(.subheadline.bold())
                        Button {

                            if let actionItemIndex = itemVM.items.firstIndex(of: item) {
                                inputHome.actionItemIndex = actionItemIndex
                                withAnimation(.easeIn(duration: 0.15)) {
                                    inputHome.isShowItemDetail.toggle()
                                }
                            } else {
                                print("インデックス取得失敗")
                            }

                        } label: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                                .opacity(0.7)

                        } // Button
                    } // HStack

                    if let itemRowTag = tagVM.tags.first(where: { $0.tagName == item.tag }) {

                        IndicatorRow(salesValue: item.sales, tagColor: tagVM.filterTagsData(selectTagName: itemRowTag.tagColor))

                    } else {

                        IndicatorRow(salesValue: item.sales, tagColor: .gray)

                    }

                    Text(item.name)
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                } // VStack
                Spacer()
            } // HStack
        } // VStack
        .padding(.top)
    } // リストレイアウト
} // View

struct ManageView_Previews: PreviewProvider {
    static var previews: some View {
        ManageView(itemVM: ItemViewModel(),
                   tagVM: TagViewModel(),
                   inputHome: .constant(InputHome()),
                   inputImage: .constant(InputImage()))
    }
}
