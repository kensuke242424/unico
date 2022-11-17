//
//  ItemViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/24.
//

import SwiftUI
import FirebaseStorage
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

    func uploadImage(_ image: UIImage) async -> (url: URL?, filePath: String?) {

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "gs://unico-cc222.appspot.com/test/test.jpeg"
            let imageRef = reference.child(filePath)
            let _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func resetAmount() {

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

    func itemsUpDownOderSort() {

        items.reverse()
    }

    func itemsValueSort(order: UpDownOrder, status: IndicatorValueStatus) {

        switch order {

        case .up:

            switch status {
            case .stock:
                items.sort(by: { $0.inventory > $1.inventory })
            case .price:
                items.sort(by: { $0.price > $1.price })
            case .sales:
                items.sort(by: { $0.sales > $1.sales })
            }

        case .down:

            switch status {
            case .stock:
                items.sort(by: { $0.inventory < $1.inventory })
            case .price:
                items.sort(by: { $0.price < $1.price })
            case .sales:
                items.sort(by: { $0.sales < $1.sales })
            }
        }
    }

    func itemsNameSort(order: UpDownOrder) {

        switch order {

        case .up:
            items.sort(by: { $0.name > $1.name })

        case .down:
            items.sort(by: { $0.name < $1.name })
        }
    }

    func itemsCreateTimeSort(order: UpDownOrder) {

        switch order {
        case .up:
            items.sort { before, after in
                before.createTime!.dateValue() > after.createTime!.dateValue() ? true : false
            }
        case .down:
            items.sort { before, after in
                before.createTime!.dateValue() < after.createTime!.dateValue() ? true : false
            }
        }
    }

    func itemsUpdateTimeSort(order: UpDownOrder) {
        switch order {
        case .up:
            items.sort { before, after in
                before.updateTime!.dateValue() > after.updateTime!.dateValue() ? true : false
            }
        case .down:
            items.sort { before, after in
                before.updateTime!.dateValue() < after.updateTime!.dateValue() ? true : false
            }
        }
    }

    deinit {

        print("<<<<<<<<<  ItemViewModel_deinit  >>>>>>>>>")
        listener?.remove()
    }

} // class
