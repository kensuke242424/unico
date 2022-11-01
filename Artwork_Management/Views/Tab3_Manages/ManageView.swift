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

    // NOTE: 新規アイテム追加Viewの発現を管理します
    @Binding var inputHome: InputHome

    struct InputManage {
        var isShowItemDetail = false
        var listIndex = 0
        var tagGroup: TagGroup = .on
        var sortType: SortType = .start
    }

    @State private var inputManage: InputManage = InputManage()

    var body: some View {

        NavigationView {
            ZStack {
                ScrollView(.vertical) {

                    VStack(alignment: .leading) {

                        // NOTE: タグ表示の「ON」「OFF」で表示を切り替えます
                        switch inputManage.tagGroup {

                        case .on:

                            // タグの要素数の分リストを作成
                            ForEach(itemVM.tags) { tagRow in

                                // firstには"ALL", lastには"タグ無し"
                                if tagRow != itemVM.tags.first! && tagRow != itemVM.tags.last! {
                                    Text(tagRow.tagName)
                                        .foregroundColor(.white)
                                        .font(.title.bold())
                                        .shadow(radius: 2, x: 4, y: 6)
                                        .padding(.vertical)

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
                            } // ForEach itemVM.tags

                            // "タグ無し"タグのついたアイテムが存在した場合
                            if itemVM.items.contains(where: {$0.tag == (itemVM.tags.last!.tagName)}) {
                                Text("\(itemVM.tags.last!.tagName)")
                                    .foregroundColor(.white)
                                    .font(.title.bold())
                                    .shadow(radius: 2, x: 4, y: 6)
                                    .padding(.vertical)

                                LinearGradient(gradient: Gradient(colors: [.gray, .clear]),
                                                           startPoint: .leading, endPoint: .trailing)
                                    .frame(height: 1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    ForEach(itemVM.items) { item in

                                        if item.tag == "\(itemVM.tags.last!.tagName)" {
                                            manageListRow(item: item)
                                        }
                                    } // ForEach item
                            } // if

                        case .off:

                            Text("- \(itemVM.tags[0].tagName) -")
                                .font(.largeTitle.bold())
                                .shadow(radius: 2, x: 4, y: 6)
                                .padding(.vertical)

                            ForEach(itemVM.items) { item in

                                manageListRow(item: item)

                            } // case .groupOff
                        } // switch tagGroup
                    } // VStack
                    .padding(.leading)

                } // ScrollView

                if inputManage.isShowItemDetail {
                    ShowsItemDetail(itemVM: itemVM,
                                    item: itemVM.items[inputManage.listIndex],
                                    itemIndex: inputManage.listIndex,
                                    isShowItemDetail: $inputManage.isShowItemDetail,
                                    isPresentedEditItem: $inputHome.isPresentedEditItem)

                } // if isShowItemDetail

            } // ZStack
            .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                                       startPoint: .top, endPoint: .bottom))
            .navigationTitle("Manage")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.spring(response: 0.5), value: inputManage.tagGroup)
            // sort Menu...
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Menu("タググループ") {

                            Button {
                                inputManage.tagGroup = .on
                            } label: {
                                if inputManage.tagGroup == .on {
                                    Text("ON   　　　　　 ✔︎")
                                } else {
                                    Text("ON")
                                }
                            } // ON

                            Button {
                                inputManage.tagGroup = .off
                            } label: {
                                if inputManage.tagGroup == .off {
                                    Text("OFF   　　　　　 ✔︎")
                                } else {
                                    Text("OFF")
                                }
                            } // OFF
                        } // タググループオプション

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
                        inputHome.isShowSystemSideMenu.toggle()
                        inputHome.sideMenuBackGround.toggle()
                    } label: {
                        CircleIcon(photo: "cloth_sample1", size: 35)
                    }
                }
            }
        } // NavigationView
    } // body

    @ViewBuilder
    func manageListRow(item: Item) -> some View {

        VStack(alignment: .leading, spacing: 20) {

            HStack(spacing: 20) {

                ShowItemPhoto(photo: item.photo, size: 70)
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

                            if let listIndex = itemVM.items.firstIndex(of: item) {
                                inputManage.listIndex = listIndex
                                inputManage.isShowItemDetail.toggle()
                                print("isShowItemDetail: \(inputManage.isShowItemDetail)")
                                print(listIndex)
                            } else {
                                print("インデックス取得失敗")
                            }

                        } label: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                                .opacity(0.7)

                        } // Button
                    } // HStack

                    // NOTE: ラインの外枠を透明フレームで置いておくことで、
                    // インジケーターが端まで行ってもレイアウトが崩れない
                    switch item.tagColor {
                    case "赤": IndicatorRow(salesValue: item.sales, tagColor: .red)
                    case "青": IndicatorRow(salesValue: item.sales, tagColor: .blue)
                    case "黄": IndicatorRow(salesValue: item.sales, tagColor: .yellow)
                    case "緑": IndicatorRow(salesValue: item.sales, tagColor: .green)
                    default: IndicatorRow(salesValue: item.sales, tagColor: .gray)
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
        ManageView(itemVM: ItemViewModel(), inputHome: .constant(InputHome()))
    }
}
