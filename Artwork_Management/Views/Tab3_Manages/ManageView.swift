//
//  SalesView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/23.
//

import SwiftUI

struct ManageView: View {

    @StateObject var itemVM: ItemViewModel
    @StateObject var tagVM: TagViewModel

    @Binding var inputHome: InputHome
    @Binding var inputImage: InputImage
    @Binding var inputManage: InputManageCustomizeSideMenu

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

                                    // firstには"ALL", lastには"未グループ"
                                    if tagRow != tagVM.tags.first! && tagRow != tagVM.tags.last! {

                                        HStack {
                                            Text(tagRow.tagName)
                                                .foregroundColor(.white)
                                                .font(.title2.bold())
                                                .shadow(radius: 2, x: 4, y: 6)
                                                .padding(.vertical)
                                        }

                                        Spacer(minLength: 0)

                                        GradientLine(color1: .gray, color2: .clear)
                                            .padding(.bottom)

                                        if itemVM.items.contains(where: {$0.tag == tagRow.tagName}) {

                                            VStack {
                                                ForEach(itemVM.items) { item in

                                                    if item.tag == tagRow.tagName {
                                                        manageListRow(item: item)
                                                    }
                                                }
                                                Spacer().frame(height: 20)

                                                HStack(alignment: .bottom) {
                                                    Spacer()
                                                    Text("\(tagRow.tagName)  売上  ¥ ")
                                                        .font(.caption)
                                                    Text(String(tagGroupTotalSales(items: itemVM.items, tag: tagRow.tagName)))
                                                }
                                                .frame(alignment: .trailing)
                                                .foregroundColor(.white.opacity(0.6))
                                                .overlay(alignment: .bottomTrailing) {
                                                    GradientLine(color1: .clear, color2: .white).opacity(0.3)
                                                        .offset(y: 7)
                                                }
                                                .padding(.vertical)
                                                .padding(.bottom, 30)
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

                                    GradientLine(color1: .gray, color2: .clear)

                                        ForEach(itemVM.items) { item in

                                            if item.tag == "\(tagVM.tags.last!.tagName)" {
                                                manageListRow(item: item)
                                            }
                                        } // ForEach item
                                } // if
                                Spacer().frame(height: 300)
                            }

                        case false:

                            Spacer().frame(height: 60)

                            Text(tagVM.tags[0].tagName)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .shadow(radius: 2, x: 4, y: 6)
                                .padding(.vertical)

                            GradientLine(color1: .gray, color2: .clear)

                            ForEach(itemVM.items) { item in

                                manageListRow(item: item)

                            } // case .groupOff

                            Spacer().frame(height: 250)

                        } // switch tagGroup
                    } // VStack
                    .padding(.horizontal)

                } // ScrollView
            } // ZStack
            .background(LinearGradient(gradient: Gradient(colors: [.customDarkGray1, .customLightGray1]),
                                       startPoint: .top, endPoint: .bottom))
            .navigationTitle("Manage")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.spring(response: 0.5), value: inputManage.isTagGroup)
            .animation(.spring(response: 0.5), value: inputManage.sortType)

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        inputHome.editItemStatus = .create
                        inputHome.isPresentedEditItem.toggle()
                    } label: {
                        Image(systemName: "shippingbox.fill")
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .offset(x: 3, y: -3)
                            }
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

        VStack {

            HStack(alignment: .top, spacing: 20) {

                ShowItemPhoto(photo: item.photo, size: UIScreen.main.bounds.width / 5)

                VStack(alignment: .leading, spacing: 13) {

                    HStack {

                        Group {
                            Text(inputManage.indicatorValueStatus.text)
                            inputManage.indicatorValueStatus.icon
                                .offset(x: -5)
                        }
                        .font(.caption).opacity(0.5)
                        .foregroundColor(.white)

                        Group {
                            switch inputManage.indicatorValueStatus {
                            case .stock:
                                Text(String(item.inventory))
                            case .price:
                                Text(item.price != 0 ? String(item.price) : "-")
                            case .sales:
                                Text(item.sales != 0 ? String(item.sales) : "-")
                            }
                        }
                        .font(.subheadline.bold()).opacity(0.5)
                        .foregroundColor(.white)
                        .frame(width: 90, alignment: .leading)
                    }
                    .overlay(alignment: .trailing) {
                        HStack {
                            inputHome.switchElement.icon.font(.caption).opacity(0.5)

                            switch inputHome.switchElement {
                            case .stock:
                                Text(" \(item.inventory)")
                            case .price:
                                Text(item.price != 0 ? " \(item.price)" : " -")
                            }
                        }
                        .padding(5)
                        .font(.caption.bold()).opacity(0.7)
                        .foregroundColor(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.black.opacity(0.2))
                        }
                        .offset(x: 80)
                    }

                    IndicatorRow(inputManage: $inputManage,
                                 item: item,
                                 color: tagVM.fetchUsedColor(tagName: item.tag))

                    Text(item.name)
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.7))
                        .offset(y: 10)
                } // VStack
                Spacer()
            } // HStack
        } // VStack
        .padding(.vertical)
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
    }

    private func switchIndicatorValue(item: Item, status: ElementStatus) -> Int {

        switch status {
        case .stock: return item.inventory
        case .price: return item.price
        }
    }

    private func tagGroupTotalSales(items: [Item], tag: String) -> Int {

        var itemsSales = 0

        for item in items.filter({ $0.tag.contains(tag)}) {
            itemsSales += item.sales
        }
        return itemsSales
    }

    func manageListSort(items: [Item], sort: SortType, order: UpDownOrder) {

    }

} // View

struct ManageView_Previews: PreviewProvider {
    static var previews: some View {
        ManageView(itemVM: ItemViewModel(),
                   tagVM: TagViewModel(),
                   inputHome: .constant(InputHome()),
                   inputImage: .constant(InputImage()),
                   inputManage: .constant(InputManageCustomizeSideMenu()))
    }
}
