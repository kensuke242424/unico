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

class ItemViewModel: ObservableObject, FirebaseErrorHandling {

    init() { print("<<<<<<<<<  ItemViewModel_init  >>>>>>>>>") }

    var listener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    @Published var items: [Item] = []

    @Published var selectedSortType: ItemsSortType = .name
    @Published var selectedOder: UpDownOrder = .down
    @Published var filteringFavorite: Bool = false

    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    /// Firestoreに保存されている現在操作チームのアイテム追加/更新/削除のステートを監視するリスナーメソッド。
    func itemsListener(id currentTeamId: String) async {

        listener = db?
            .collection("teams")
            .document(currentTeamId)
            .collection("items")
            .addSnapshotListener { (snap, error) in
                if let error {
                    assertionFailure("ERROR: \(error.localizedDescription)")
                    return
                }
                guard let documents = snap?.documents else {
                    assertionFailure("ERROR: snapshot_nil")
                    return
                }

                withAnimation {
                    self.items = documents.compactMap { (snap) -> Item? in
                        do {
                            let item = try snap.data(as: Item.self, with: .estimate)
                            return item
                        } catch {
                            self.handleErrors([error])
                            return nil
                        }
                    } // compactMap
                    self.selectedTypesSort()
                }
            }
    }

    func addOrUpdateItem(_ item: Item, teamId: String?) async {
        guard let teamId else { assertionFailure("teamId: nil"); return }

        do {
            try await Item.setData(.items(teamId: teamId), docId: item.id, data: item)
        } catch {
            handleErrors([error])
        }
    }

    func deleteItem(deleteItem: Item, teamId: String?) async {
        guard let teamId else { assertionFailure("teamId: nil"); return }

        do {
            try await Item.deleteDocument(.items(teamId: teamId), docId: deleteItem.id)
        } catch {
            handleErrors([error])
        }
    }

    func uploadItemImage(_ image: UIImage?, _ teamId: String) async -> (url: URL?, filePath: String?) {
        do {
            let data = try await FirebaseStorageManager.uploadImage(image, .item(teamId: teamId))
            return (url: data.url, filePath: data.filePath)

        } catch {
            handleErrors([error])
            return (url: nil, filePath: nil)
        }
    }

    func deleteImage(path: String?) async {
        do {
            try await FirebaseStorageManager.deleteImage(path: path)
        } catch {
            handleErrors([error])
        }
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
        removeListener()
    }
} // class
