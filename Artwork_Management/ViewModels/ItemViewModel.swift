//
//  ItemViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class ItemViewModel: ObservableObject {

    init() { print("<<<<<<<<<  ItemViewModel_init  >>>>>>>>>") }

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    // NOTE: アイテム、タグのテストデータです
     @Published var items: [Item] = []

    @Published var tags: [Tag] =
    [
        Tag(tagName: "ALL", tagColor: .gray),
        Tag(tagName: "Clothes", tagColor: .red),
        Tag(tagName: "Shoes", tagColor: .blue),
        Tag(tagName: "タオル", tagColor: .blue),
        Tag(tagName: "Goods", tagColor: .yellow),
        Tag(tagName: "未グループ", tagColor: .gray)
    ]

    func fetchItem(userID: String) {

        print("fetchItem実行")

        guard db != nil else { return }

        listener = db!.collection("items").addSnapshotListener { (snap, _) in

            guard let documents = snap?.documents else {
                print("Error: guard let documents = snap?.documents")
                return
            }

            // 取得できたアイテムをデコーダブル ⇨ Itemモデルを参照 ⇨ 「items」に詰めていく
            // with: ⇨ ServerTimestampを扱う際のオプションを指定
            self.items = documents.compactMap { (snap) -> Item? in

                return try? snap.data(as: Item.self, with: .estimate)
            }
        }
        print("fetchItem完了")
    }

    func addItem(itemData: Item, tag: String, userID: String) {

        print("addItem実行")

        guard db != nil else { return }

        do {
            _ = try db!.collection("items").addDocument(from: itemData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
        }
        print("addItem完了")
    }

    func updateItem(updateData: Item, defaultDataID: String) {

        print("updateItem実行")

        guard  let reference = db?.collection("items").document(defaultDataID) else { print("Error: guard  let reference"); return }

        do {

            try reference.setData(from: updateData)

        } catch {
            print("updateItem失敗")
        }
        print("updateItem完了")
    }

    func resetAmount() {
        print("resetAmount実行")

        guard let reference = db?.collection("items") else { print("Error: guard db != nil"); return }

        for index in items.indices where items[index].amount != 0 {

            guard let itemID = items[index].id else {
                print("Error: 「\(items[index].name)」 guard let = item.id")
                continue
            }

            items[index].amount = 0

            do {
                try reference.document(itemID).setData(from: items[index])

            } catch {
                print("Error: 「\(items[index].name)」try reference.document(itemID).setData(from: item)")
            }
        }
        print("resetAmount完了")
    }

    func updateCommerseItems() {

        print("updateCommerse実行")

        guard let reference = db?.collection("items") else { print("Error: guard db != nil"); return }

        for item in items where item.amount != 0 {

            guard let itemID = item.id else {
                print("Error: 「\(item.name)」 guard let = item.id")
                continue
            }

            var item = item

            item.updateTime = nil // nilを代入することで、保存時にTimestamp発火
            item.sales += item.price * item.amount
            item.inventory -= item.amount
            item.totalAmount += item.amount
            item.amount = 0

            do {
                try reference.document(itemID).setData(from: item)
            } catch {
                print("Error: 「\(item.name)」try reference.document(itemID).setData(from: item)")
            }
        }
        print("updateCommerse完了")
    }

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
    }

    func searchSelectTagColor(selectTagName: String, tags: [Tag]) -> UsedColor {

        let filterTag = tags.filter { $0.tagName == selectTagName }

        if let firstFilterTag = filterTag.first {

            return firstFilterTag.tagColor

        } else {
            return.gray
        }
    } // func castStringIntoColor

    func updateTagsData(itemVM: ItemViewModel,
                        defaultTag: Tag,
                        newTagName: String,
                        newTagColor: UsedColor) {

        for (index, tagData) in itemVM.tags.enumerated()
        where tagData.tagName == defaultTag.tagName {

            itemVM.tags[index] = Tag(tagName: newTagName,
                                     tagColor: newTagColor)

        } // for where
    } // func updateTagsData

    func updateItemsTagData(itemVM: ItemViewModel,
                            defaultTag: Tag,
                            newTagName: String,
                            newTagColorString: String) {

        // NOTE: アイテムデータ内の更新対象タグを取り出して、同じタググループアイテムをまとめて更新します。
        for (index, itemData) in itemVM.items.enumerated()
        where itemData.tag == defaultTag.tagName {

            itemVM.items[index].tag = newTagName

        } // for where
    } // func updateItemsTagData

    deinit {

        print("<<<<<<<<<  ItemViewModel_deinit  >>>>>>>>>")
        listener?.remove()
    }

} // class

struct TestItem {

    var testItem: Item = Item(tag: "Clothes",
                              name: "カッターシャツ(白)",
                              detail: "シャツ(白)のアイテム紹介テキストです。",
                              photo: "cloth_sample1",
                              cost: 1000,
                              price: 2800,
                              amount: 0,
                              sales: 128000,
                              inventory: 2,
                              totalAmount: 120,
                              totalInventory: 200)
}
