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

    /// View Properties...
    @Published var items: [Item] = []
    @Published var selectedSortType: ItemsSortType = .name
    @Published var selectedOder: UpDownOrder = .down
    @Published var filteringFavorite: Bool = false

    var currentTeamID: String? {
        guard let item = self.items.first else { return nil }
        return item.teamID
    }
    /// 初回のデータフェッチが完了したかを判定するプロパティ。
    /// アプリ起動によるFirestoreからの初期値フェッチ時、リスナーの「.added」に全アイテムの取得フラグが入ってくるため、
    /// 初回のフラグのみをフラグ取得から除外するために使う。

    /// アイテムデータの追加・更新・削除のステートを管理するリスナーメソッド。
    /// 初期実行時にリスニング対象ドキュメントのデータが全取得される。(フラグはadded)
    func itemsListener(id currentTeamID: String) async {
        print("itemsListener起動")
        let itemsRef = db?.collection("teams").document(currentTeamID).collection("items")
        guard let itemsRef else { return }

        listener = itemsRef.addSnapshotListener { (snap, _) in
            guard let snap = snap else {
                print("Error: itemsListener_snap nil")
                return
            }
            snap.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let item = try? diff.document.data(as: Item.self, with: .estimate)
                    guard let item else { return }
                    withAnimation {self.items.append(item)}
                    withAnimation {self.selectedTypesSort()}
                    print("新規アイテムの追加: \(item.name)")
                }
                if (diff.type == .modified) {
                    let item = try? diff.document.data(as: Item.self, with: .estimate)
                    guard let item else { return }
                    guard let _ = item.updateTime else { return } // Timestamp更新前のフラグを除外
                    guard let index = self.items.firstIndex(where: {$0.id == item.id}) else { return }
                    withAnimation {self.items[index] = item}
                    withAnimation {self.selectedTypesSort()}
                    print("既存アイテムの更新: \(item)")
                }
                if (diff.type == .removed) {
                    let item = try? diff.document.data(as: Item.self, with: .estimate)
                    guard let item else { return }
                    guard let _ = item.updateTime else { return } // Timestamp更新前のフラグを除外
                    withAnimation {self.items.removeAll(where: {$0.id == item.id})}
                    print("データ削除を確認: \(item)")
                }
            }
        }
    }

    /// Firestoreからチームの全アイテムをフェッチするメソッド。初回起動時に呼ばれる。
    @MainActor func fetchAllItem(teamID: String) async throws {
        guard let itemRefs = db?.collection("teams")
            .document(teamID)
            .collection("items") else {
            print("ERROR: fetchAllItem_guard let itemRefs")
            return
        }
        let snapshot = try await itemRefs.getDocuments()
        self.items = snapshot.documents.compactMap { (document) -> Item? in
            return try? document.data(as: Item.self, with: .estimate)
        }
        self.selectedTypesSort() // ソート
    }

    /// 指定idのアイテム一つをFirestoreから取得するメソッド。
    func fetchOneItem(teamID: String, itemID: String) async -> Item? {
        guard let itemRef = db?.collection("teams")
            .document(teamID)
            .collection("items")
            .document(itemID) else {
            print("error: guard let itemRef")
            return nil
        }

        do {
            let itemDocument = try await itemRef.getDocument()
            let itemData = try itemDocument.data(as: Item.self)
            return itemData
        } catch {
            return nil
        }
    }

    func addItem(itemData: Item, tag: String, teamID: String) {

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

    func updateItem(updateData: Item, defaultDataID: String, teamID: String) {

        print("updateItem実行")
        print(defaultDataID)

        guard let updateItemRef = db?.collection("teams").document(teamID).collection("items").document(defaultDataID) else {
            print("error: guard let updateItemRef")
            return
        }

        do {

            try updateItemRef.setData(from: updateData)

        } catch {
            print("updateItem失敗")
        }
        print("updateItem完了")
    }

    func deleteItem(deleteItem: Item, teamID: String) {

        guard let itemID = deleteItem.id else { return }
        guard let itemRef = db?.collection("teams").document(teamID).collection("items").document(itemID) else {
            print("error: deleteItem_guard let ItemRef")
            return
        }

        itemRef.delete()
    }
    
    func updateFavorite(_ item: Item) {
        print("updateFavoriteメソッド実行")

        guard let itemsRef = db?.collection("teams").document(item.teamID).collection("items") else {
            print("error: guard let itemsRef")
            return
        }
        guard let itemID = item.id else { return }
        
        var item = item
        item.favorite.toggle()

        do {
            try itemsRef.document(itemID).setData(from: item)
        } catch {
            hapticErrorNotification()
            print("updateFavoriteメソッド失敗")
        }
        hapticSuccessNotification()
        print("updateFavoriteメソッド完了")
    }
    
    func resizeUIImage(image: UIImage?, width: CGFloat) -> UIImage? {
        
        if let originalImage = image {
            // オリジナル画像のサイズからアスペクト比を計算
            let aspectScale = originalImage.size.height / originalImage.size.width
            
            // widthからアスペクト比を元にリサイズ後のサイズを取得
            let resizedSize = CGSize(width: width * 3, height: width * Double(aspectScale) * 3)
            
            // リサイズ後のUIImageを生成して返却
            UIGraphicsBeginImageContext(resizedSize)
            /// MEMO: 保存後の画像heightに少しだけ隙間ができるので、resizedSize.height + 1で対応してる
            originalImage.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height + 1))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage
        } else {
            return nil
        }
    }

    func uploadItemImage(_ image: UIImage?, _ teamID: String) async -> (url: URL?, filePath: String?) {
        
        print("uploadImage実行")
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "/teams/\(teamID)/items/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()
            print("uploadImage完了")

            return (url: url, filePath: filePath)
        } catch {
            print("uploadImage失敗")
            return (url: nil, filePath: nil)
        }
    }

    func deleteImage(path: String?) {

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
    
    func deleteAllItemImages() async {
        let storage = Storage.storage()
        let reference = storage.reference()
        
        for item in items {
            guard let itemPath = item.photoPath else { continue }
            let imageRef = reference.child(itemPath)
            imageRef.delete { error in
                if let error = error {
                    print("画像の削除に失敗しました: \(error.localizedDescription)")
                } else {
                    print("\(item.name)の画像削除に成功しました")
                }
            }
        }
    }

    func resetAmount() {

        for index in items.indices where items[index].amount != 0 {
            items[index].amount = 0
        }
        print("resetAmount完了")
    }

    func updateCommerseItems(teamID: String) {

        print("updateCommerse実行")

        guard let itemsRef = db?.collection("teams").document(teamID).collection("items") else {
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
    /// 選択されているソートタイプに応じてitemsを並び替えするメソッド。
    func selectedTypesSort() {
        switch selectedSortType {
        case .name      : nameSort()
        case .createTime: createTimeSort()
        case .updateTime: updateTimeSort()
        case .sales     : updateTimeSort()
        }
    }

    func upDownOderSort() {
        items.reverse()
    }

    func valueSort(order: UpDownOrder, status: IndicatorValueStatus) {

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

    func nameSort() {

        switch self.selectedOder {

        case .up:
            items.sort(by: { $0.name > $1.name })

        case .down:
            items.sort(by: { $0.name < $1.name })
        }
    }

    func createTimeSort() {

        switch self.selectedOder {
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

    func updateTimeSort() {
        switch self.selectedOder {
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
