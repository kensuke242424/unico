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
        Item(tag: "Clothes", tagColor: "赤", name: "カッターシャツ(白)", detail: "シャツ(白)のアイテム紹介テキストです。", photo: "cloth_sample1",
             price: 2800, sales: 128000, inventory: 2, createTime: Date(), updateTime: Date()),
        Item(tag: "Clothes", tagColor: "赤", name: "トップス(黒)", detail: "トップス(黒)のアイテム紹介テキストです。", photo: "cloth_sample2",
             price: 3800, sales: 80000, inventory: 4, createTime: Date(), updateTime: Date()),
        Item(tag: "Clothes", tagColor: "赤", name: "Tシャツ(黒)", detail: "Tシャツ(黒)のアイテム紹介テキストです。", photo: "cloth_sample4",
             price: 3200, sales: 107000, inventory: 402, createTime: Date(), updateTime: Date()),
        Item(tag: "Shoes", tagColor: "青", name: "シューズ(灰)", detail: "シューズ1のアイテム紹介テキストです。", photo: "shoes_sample1",
             price: 8800, sales: 182000, inventory: 199, createTime: Date(), updateTime: Date()),
        Item(tag: "Shoes", tagColor: "青", name: "シューズ(赤)", detail: "シューズ2のアイテム紹介テキストです。", photo: "shoes_sample2",
             price: 13100, sales: 105000, inventory: 43, createTime: Date(), updateTime: Date()),
        Item(tag: "Shoes", tagColor: "青", name: "シューズ(白)", detail: "シューズ3のアイテム紹介テキストです。", photo: "shoes_sample3",
             price: 10700, sales: 185000, inventory: 97, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "オリジナルキャップ", detail: "グッズ「オリジナルキャップ」のアイテム紹介テキストです。", photo: "goods_sample6",
             price: 4300, sales: 59000, inventory: 88, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "トートバッグ(黒)", detail: "グッズ「トートバッグ」のアイテム紹介テキストです。", photo: "goods_sample5",
             price: 2500, sales: 39000, inventory: 105, createTime: Date(), updateTime: Date()),
        Item(tag: "Goods", tagColor: "黄", name: "マグカップ", detail: "グッズ「マグカップ」のアイテム紹介テキストです。", photo: "goods_sample3",
             price: 2000, sales: 22000, inventory: 97, createTime: Date(), updateTime: Date())
    ]

    @Published var tags: [Tag] =
    [
        Tag(tagName: "Clothes", tagColor: .red),
        Tag(tagName: "Shoes", tagColor: .blue),
        Tag(tagName: "Goods", tagColor: .yellow)
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
    func searchSelectTagColor(selectTagName: String, tags: [Tag]) -> UsedColor {

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

    // ✅ メソッド: 変更内容をもとに、tags内の対象データのタグネーム、タグカラーを更新します。
    func updateTagsData(itemVM: ItemViewModel,
                        itemTagName: String,
                        selectTagName: String,
                        selectTagColor: UsedColor) {

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
    func updateItemsTagData(itemVM: ItemViewModel,
                            itemTagName: String,
                            newTagName: String,
                            newTagColorString: String) {

        print("ーーーーーーー　updateItemsTagDataメソッド_実行　ーーーーーーーーー")

        // NOTE: アイテムデータ内の更新対象タグを取り出して、同じタググループアイテムをまとめて更新します。
        for (index, itemData) in itemVM.items.enumerated()
        where itemData.tag == itemTagName {

            itemVM.items[index].tag = newTagName
            itemVM.items[index].tagColor = newTagColorString

            print("更新されたitemVM.items: \(itemVM.items[index])")

        } // for where
    } // func updateItemsTagData

    func nowDateTime(date: Date, type: String) -> String {
        let month: String
        let week: String
        let day = Calendar.current.component(.day, from: date)
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)

        switch type {
        case "date":

            switch Calendar.current.component(.month, from: date) {
            case 1: month = "Jan."
            case 2: month = "Feb."
            case 3: month = "Mar."
            case 4: month = "Apr."
            case 5: month = "May"
            case 6: month = "Jun."
            case 7: month = "Jul."
            case 8: month = "Aug."
            case 9: month = "Sept."
            case 10: month = "Oct."
            case 11: month = "Nov."
            case 12: month = "Dec."
            default: month =  "-"

            }

            switch Calendar.current.component(.weekday, from: date) {
            case 1: week = "Sun"
            case 2: week = "Mon"
            case 3: week = "Thu"
            case 4: week = "Wed"
            case 5: week = "Thu"
            case 6: week = "Fri"
            case 7: week = "Sat"
            default: week =  "-"
            }

            return "\(month) \(week) \(day)"

        case "time":

            let hour =  String(hour)
            let minute = String(minute).count == 1 ? "0\(minute)" : String(minute)
            let second = String(second).count == 1 ? "0\(second)" : String(second)

            return "\(hour):\(minute):\(second)"

        default:
            return "Time_Error"
        }
    }

} // class

struct TestItem {

    var testItem: Item = Item(tag: "Clothes",
                              tagColor: "赤",
                              name: "カッターシャツ(白)",
                              detail: "シャツ(白)のアイテム紹介テキストです。",
                              photo: "cloth_sample1",
                              price: 2800,
                              sales: 128000,
                              inventory: 2,
                              createTime: Date(),
                              updateTime: Date())
}
