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

    @Published var rootItems: [RootItem] = []

    func fetchItem(teamID: String) async {

        print("fetchItem実行")

        guard let itemsRef = db?.collection("teams").document(teamID).collection("items") else {
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
            self.rootItems = documents.compactMap { (snap) -> RootItem? in

                return try? snap.data(as: RootItem.self, with: .estimate)
            }
        }
        print("fetchItem完了")
    }

    func addItem(itemData: RootItem, tag: String, teamID: String) {

        print("addItem実行")

        guard let itemsRef = db?.collection("teams").document(teamID).collection("items") else {
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

    func updateItem(updateData: RootItem, defaultDataID: String, teamID: String) {

        print("updateItem実行")

        print(defaultDataID)

        guard let updateItemRef = db?.collection("teams").document(teamID).collection("items").document(defaultDataID) else {
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

    func deleteItem(deleteItem: RootItem, teamID: String) {

        guard let itemID = deleteItem.id else { return }
        guard let itemRef = db?.collection("teams").document(teamID).collection("items").document(itemID) else {
            print("error: deleteItem_guard let ItemRef")
            return
        }

        itemRef.delete()
    }

    func uploadImage(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "images/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func deleteImage(path: String?) async {

        guard let path = path else { return }

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("imageRef.delete succsess!")
            }
        }
    }

    func resetAmount() {

        for index in rootItems.indices where rootItems[index].amount != 0 {
            rootItems[index].amount = 0
        }
        print("resetAmount完了")
    }

    func updateCommerseItems(teamID: String) {

        print("updateCommerse実行")

        guard let itemsRef = db?.collection("teams").document(teamID).collection("items") else {
            print("error: guard let tagsRef")
            return
        }

        for item in rootItems where item.amount != 0 {

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

        rootItems.reverse()
    }

    func itemsValueSort(order: UpDownOrder, status: IndicatorValueStatus) {

        switch order {

        case .up:

            switch status {
            case .stock:
                rootItems.sort(by: { $0.inventory > $1.inventory })
            case .price:
                rootItems.sort(by: { $0.price > $1.price })
            case .sales:
                rootItems.sort(by: { $0.sales > $1.sales })
            }

        case .down:

            switch status {
            case .stock:
                rootItems.sort(by: { $0.inventory < $1.inventory })
            case .price:
                rootItems.sort(by: { $0.price < $1.price })
            case .sales:
                rootItems.sort(by: { $0.sales < $1.sales })
            }
        }
    }

    func itemsNameSort(order: UpDownOrder) {

        switch order {

        case .up:
            rootItems.sort(by: { $0.name > $1.name })

        case .down:
            rootItems.sort(by: { $0.name < $1.name })
        }
    }

    func itemsCreateTimeSort(order: UpDownOrder) {

        switch order {
        case .up:
            rootItems.sort { before, after in
                before.createTime!.dateValue() > after.createTime!.dateValue() ? true : false
            }
        case .down:
            rootItems.sort { before, after in
                before.createTime!.dateValue() < after.createTime!.dateValue() ? true : false
            }
        }
    }

    func itemsUpdateTimeSort(order: UpDownOrder) {
        switch order {
        case .up:
            rootItems.sort { before, after in
                before.updateTime!.dateValue() > after.updateTime!.dateValue() ? true : false
            }
        case .down:
            rootItems.sort { before, after in
                before.updateTime!.dateValue() < after.updateTime!.dateValue() ? true : false
            }
        }
    }

    deinit {

        print("<<<<<<<<<  ItemViewModel_deinit  >>>>>>>>>")
        listener?.remove()
    }

} // class
