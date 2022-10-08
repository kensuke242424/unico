//
//  ItemViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import Foundation
import SwiftUI

class ItemViewModel: ObservableObject {

    // NOTE: アイテム、タグのテストデータです
     @Published var items: [Item] =
    [
        Item(tag: "Album", tagColor: "赤", name: "Album1", detail: "Album1のアイテム紹介テキストです。", photo: "",
             price: 1800, sales: 88000, inventory: 200, createTime: Date(), updateTime: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album2", detail: "Album2のアイテム紹介テキストです。", photo: "",
             price: 2800, sales: 230000, inventory: 420, createTime: Date(), updateTime: Date()),
        Item(tag: "Album", tagColor: "赤", name: "Album3", detail: "Album3のアイテム紹介テキストです。", photo: "",
             price: 3200, sales: 367000, inventory: 402, createTime: Date(), updateTime: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single1", detail: "Single1のアイテム紹介テキストです。", photo: "",
             price: 1100, sales: 182000, inventory: 199, createTime: Date(), updateTime: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single2", detail: "Single2のアイテム紹介テキストです。", photo: "",
             price: 1310, sales: 105000, inventory: 43, createTime: Date(), updateTime: Date()),
        Item(tag: "Single", tagColor: "青", name: "Single3", detail: "Single3のアイテム紹介テキストです。", photo: "",
             price: 1470, sales: 185000, inventory: 97, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ1", detail: "グッズ1のアイテム紹介テキストです。", photo: "",
             price: 2300, sales: 329000, inventory: 88, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ2", detail: "グッズ2のアイテム紹介テキストです。", photo: "",
             price: 3300, sales: 199000, inventory: 105, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "グッズ3", detail: "グッズ3のアイテム紹介テキストです。", photo: "",
             price: 4000, sales: 520000, inventory: 97, createTime: Date(), updateTime: Date())
    ]

    @Published var tags: [Tag] =
    [
//        Tag(tagName: "Album", tagColor: .red),
//        Tag(tagName: "Single", tagColor: .blue),
//        Tag(tagName: "Goods", tagColor: .yellow)
    ]

    // ✅ NOTE: アイテム配列を各項目に沿ってソートするメソッド
    func itemsSort(sort: SortType, items: [Item]) -> [Item] {

        print("＝＝＝＝＝＝＝＝itemsSortメソッド実行＝＝＝＝＝＝＝＝＝＝")

        // NOTE: 更新可能なvar値として再格納しています
        var varItems = items

        switch sort {

        case .salesUp:
            varItems.sort { $0.sales > $1.sales }
        case .salesDown:
            varItems.sort { $0.sales < $1.sales }
        case .createAtUp:
            print("createAtUp ⇨ Timestampが格納され次第、実装します。")
        case .updateAtUp:
            print("updateAtUp ⇨ Timestampが格納され次第、実装します。")
        case .start:
            print("起動時の初期値です")
        }

        return varItems
    } // func itemsSortr

    // ✅ NOTE: 新規アイテム作成時に選択したタグの登録カラーを取り出します。
    func searchSelectTagColor(selectTagName: String, tags: [Tag]) -> Color {

        print("＝＝＝＝＝＝＝searchSelectTagColor_実行＝＝＝＝＝＝＝＝＝")

        let filterTag = tags.filter { $0.tagName == selectTagName }

        print("　filterで取得したタグデータ: \(filterTag)")

        if let firstFilterTag = filterTag.first {

            print("　現在選択タグ「\(selectTagName)」の登録タグColor: \(firstFilterTag.tagColor)")

            return firstFilterTag.tagColor

        } else {
            print("　firstFilterTagの取得に失敗しました")
            return.gray
        }
    } // func castStringIntoColor

    // ✅ NOTE: String型の色データをもとに、当てはまるColorデータを返します
    func castStringIntoColor(color: String) -> Color {

        print("===========castStringIntoColor実行=============")
        print("　引数で受け取ったstring値: 「\(color)」")

        switch color {
        case "赤":
            print("　赤と判定されました。「.red」が返り値です。")
            return .red
        case "青":
            print("　青と判定されました。「.blue」が返り値です。")
            return .blue
        case "黄":
            print("　黄と判定されました。「.yellow」が返り値です。")
            return .yellow
        case "緑":
            print("　緑と判定されました。「.green」が返り値です。")
            return .green
        default:
            print("　どれにも判定されませんでした。「.gray」が返り値です。")
            return .gray

        }
    } // func castStringIntoColor

    // ✅ NOTE: Color型の色データをもとに、当てはまるStringデータを返します
    func castColorIntoString(color: Color) -> String {

        print("===========castColorIntoString実行=============")
        print("　引数で受け取ったColor値: 「\(color)」")

        switch color {
        case .red:
            print("　.redと判定されました。返り値は「赤」です。")
            return "赤"

        case .blue:
            print("　.blueと判定されました。返り値は「青」です。")
            return "青"

        case .yellow:
            print("　.yellowと判定されました。返り値は「黄」です。")
            return "黄"

        case .green:
            print("　.greenと判定されました。返り値は「緑」です。")
            return "緑"

        default:
            print("　どれも判定されませんでした。返り値は「灰」です。")
            return "灰"

        }
    } // func castColorIntoString

    // ✅ メソッド: 変更内容をもとに、tags内の対象データのタグネーム、タグカラーを更新します。
    func updateTagsData(itemVM: ItemViewModel, itemTagName: String, selectTagName: String, selectTagColor: Color) {

        print("ーーーーーーー　updateTagsDataメソッド_実行　ーーーーーーーーー")

        // NOTE: for where文で更新対象要素を選出し、enumurated()でデータとインデックスを両方取得します。
        for (index, tagData) in itemVM.tags.enumerated()
        where tagData.tagName == itemTagName {

            itemVM.tags[index] = Tag(tagName: selectTagName,
                                     tagColor: selectTagColor)

            print("更新されたitemVM.tags: \(itemVM.tags[index])")

        } // for where
    } // func updateTagsData

    // ✅ メソッド: 変更内容をもとに、items内の対象データのタグネーム、タグカラーを更新します。
    func updateItemsTagData(itemVM: ItemViewModel, itemTagName: String,
                            newTagName: String, newTagColorString: String) {

        print("ーーーーーーー　updateItemsTagDataメソッド_実行　ーーーーーーーーー")

        // NOTE: アイテムデータ内の更新対象タグを取り出して、同じタググループアイテムをまとめて更新します。
        for (index, itemData) in itemVM.items.enumerated()
        where itemData.tag == itemTagName {

            itemVM.items[index].tag = newTagName
            itemVM.items[index].tagColor = newTagColorString

            print("更新されたitemVM.items: \(itemVM.items[index])")

        } // for where
    } // func updateItemsTagData

} // class
