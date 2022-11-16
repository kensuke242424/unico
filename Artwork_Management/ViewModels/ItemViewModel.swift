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

    var groupID: String = "7gm2urHDCdZGCV9pX9ef"

    @Published var items: [Item] = []

    func fetchItem() async {

        print("fetchItem実行")

        guard let itemsRef = db?.collection("groups").document(groupID).collection("items") else {
            print("error: guard let tagsRef")
            return
        }

        listener = itemsRef.addSnapshotListener { (snap, _) in

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

        guard let itemsRef = db?.collection("groups").document(groupID).collection("items") else {
            print("error: guard let tagsRef")
            return
        }

        do {
            _ = try itemsRef.addDocument(from: itemData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
        }
        print("addItem完了")
    }

    func updateItem(updateData: Item, defaultDataID: String) {

        print("updateItem実行")

        print(defaultDataID)

        guard let updateItemRef = db?.collection("groups").document(groupID).collection("items").document(defaultDataID) else {
            print("error: guard let tagsRef")
            return
        }

        do {

            try updateItemRef.setData(from: updateData)

        } catch {
            print("updateItem失敗")
        }
        print("updateItem完了")
    }

    func deleteItem(deleteItem: Item) {

        guard let itemID = deleteItem.id else { return }
        guard let itemRef = db?.collection("groups").document(groupID).collection("items").document(itemID) else {
            print("error: deleteItem_guard let ItemRef")
            return
        }

        itemRef.delete()
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

        guard let itemsRef = db?.collection("groups").document(groupID).collection("items") else {
            print("error: guard let tagsRef")
            return
        }

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
                try itemsRef.document(itemID).setData(from: item)
            } catch {
                print("Error: 「\(item.name)」try reference.document(itemID).setData(from: item)")
            }
        }
        print("updateCommerse完了")
    }

    func itemsSort(sort: UpDownOrder, items: [Item]) -> [Item] {

        print("＝＝＝＝＝＝＝＝itemsSortメソッド実行＝＝＝＝＝＝＝＝＝＝")

        // NOTE: 更新可能なvar値として再格納しています
        var varItems = items

        switch sort {

        case .up:
            varItems.sort { $0.sales > $1.sales }
        case .down:
            varItems.sort { $0.sales < $1.sales }
//        case .createAtUp:
//            varItems.sort { before, after in
//
//                before.createTime!.dateValue() > after.createTime!.dateValue() ? true : false
//            }
//        case .updateAtUp:
//            varItems.sort { before, after in
//
//                before.updateTime!.dateValue() > after.updateTime!.dateValue() ? true : false
//            }
//        case .start:
//            print("起動時の初期値です")
        }

        return varItems
    }

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
