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
        listener = db?
            .collection("teams")
            .document(currentTeamID)
            .collection("items")
            .addSnapshotListener { (snap, _) in
            guard let documents = snap?.documents else {
                print("ERROR: snapshot_nil")
                return
            }
            // 取得できたアイテムをデコーダブル ⇨ Itemモデルを参照 ⇨ 「items」に詰めていく
            // with: ⇨ ServerTimestampを扱う際のオプションを指定
            withAnimation {
                self.items = documents.compactMap { (snap) -> Item? in

                    return try? snap.data(as: Item.self, with: .estimate)
                }
                self.selectedTypesSort()
            }
        }
    }

    /// Firestoreからチームの全アイテムをフェッチするメソッド。初回起動時に呼ばれる。
    @MainActor
    func fetchAllItem(teamID: String) async throws {
        guard let itemRefs = db?.collection("teams")
            .document(teamID)
            .collection("items") else {
            print("ERROR: fetchAllItem_guard let itemRefs")
            return
        }
        let snapshot = try await itemRefs.getDocuments()
        self.items = snapshot.documents.compactMap { (document) -> Item? in
            return try? document.data(as: Item.self)
        }
        self.selectedTypesSort() // ソート
    }
    /// Firestoreから一つのアイテムを取得するメソッド。
    /// 主に、新規追加したアイテムをすぐに使用したい場合に用いる。
    /// ドキュメントIDはサーバーへ保存されたときに生成されるため、アイテムのcreateTimeをクエリに使う。
    func getOneItemToFirestore(from item: Item) async -> Item? {
        print("getOneItemToFirestore実行")
        guard let teamId = currentTeamID else { return nil }
        guard let itemsRef = db?.collection("teams")
            .document(teamId)
            .collection("items") else { return nil }

        var resultItem: [Item]?
        let oneItemQuery = itemsRef
            .whereField("createTime", isEqualTo: item.createTime)

        do {
            let snapshot = try await oneItemQuery.getDocuments()
            resultItem = snapshot.documents.compactMap { (document) -> Item? in
                return try? document.data(as: Item.self)
            }
            return resultItem?.first
        } catch {
            return nil
        }
    }

    func addItemToFirestore(_ itemData: Item) async {
        guard let teamId = currentTeamID, let itemId = itemData.id else { return }
        let itemRef = db?.collection("teams")
            .document(teamId)
            .collection("items")
            .document(itemId)

        do {
            _ = try db?
                .collection("teams")
                .document(teamId)
                .collection("items")
                .document(itemId)
                .setData(from: itemData)
        } catch {
            print("Error: addDocument")
        }
        print("addItem完了")
    }

    func updateItemToFirestore(_ updateItem: Item) {
        print("updateItem実行")

        guard let teamId = currentTeamID else { return }
        guard let itemId = updateItem.id else { return }
        guard let itemRef = db?.collection("teams")
            .document(teamId)
            .collection("items")
            .document(itemId) else {
            print("ERROR: getItemRef")
            return
        }

        do {
            try itemRef.setData(from: updateItem)
        } catch {
            print("updateItem失敗")
        }
        print("updateItem完了")
    }

    func deleteItem(deleteItem: Item, teamID: String) {

        guard let itemID = deleteItem.id else { return }
        guard let itemRef = db?.collection("teams")
            .document(teamID)
            .collection("items")
            .document(itemID) else {
            print("error: deleteItem_guard let ItemRef")
            return
        }
        itemRef.delete()
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
    
    func deleteAllItemImages(for team: Team?) async {
        guard let team else { return }
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

            item.updateTime = Date()
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
                before.createTime > after.createTime ? true : false
            }
        case .down:
            items.sort { before, after in
                before.createTime < after.createTime ? true : false
            }
        }
    }
    func updateTimeSort() {
        switch self.selectedOder {
        case .up:
            items.sort { before, after in
                before.updateTime > after.updateTime ? true : false
            }
        case .down:
            items.sort { before, after in
                before.updateTime < after.updateTime ? true : false
            }
        }
    }
    /// アイテムドキュメントのリスナーを削除するメソッド。
    func removeListener() {
        listener?.remove()
    }

    deinit {
        print("<<<<<<<<<  ItemViewModel_deinit  >>>>>>>>>")
        listener?.remove()
    }

} // class
