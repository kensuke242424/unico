//
//  TagViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/12.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class TagViewModel: ObservableObject, FirebaseErrorHandling {

    init() {
        print("<<<<<<<<<  TagViewModel_init  >>>>>>>>>")
    }

    var tagListener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    @Published var tags: [Tag] = []
    @Published var activeTag: Tag? // 選択中のタグ

    @Published var showEdit: Bool = false

    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    func tagsLister(teamID: String) async {
        tagListener = db?
            .collection("teams")
            .document(teamID)
            .collection("tags")
            .addSnapshotListener { (snaps, error) in

            if let error {
                assertionFailure("ERROR: \(error.localizedDescription)")
                return
            }
            guard let documents = snaps?.documents else {
                print("ERROR: snap_nil")
                return
            }

            self.tags = documents.compactMap { (snap) -> Tag? in
                do {
                    return try snap.data(as: Tag.self, with: .estimate)
                } catch {
                    self.handleErrors([error])
                    return nil
                }
            }

            self.tags.sort { $0.oderIndex < $1.oderIndex }

            // firestoreからタグのfetch後、ローカル環境にALLと未グループを追加
            self.tags.insert(Tag(oderIndex: 0, tagName: "全て", tagColor: .gray), at: 0)
            self.tags.append(Tag(oderIndex: self.tags.count, tagName: "未グループ", tagColor: .gray))
        }
    }

    /// タグデータをFireStoreから取得した後、アイテムタブビュー内にある選択タグの初期値をセットするメソッド。
    func setFirstActiveTag() {
        self.activeTag = tags.first
    }

    /// アイテム編集画面で選択されたタグを、アイテムタブビュー内のアクティブタグと同期させるメソッド。
    func setActiveTag(from setTagName: String) {
        let setTag = self.tags.first(where: { $0.tagName == setTagName })
        self.activeTag = setTag
    }

    func addOrUpdateTag(_ tagData: Tag, teamId: String) async {

        do {
            try await Tag.setData(.tags(teamId: teamId), docId: tagData.id, data: tagData)
        } catch {
            handleErrors([error])
        }
    }

    func updateOderTagIndex(teamId: String) async {
        for (index, tag) in tags.enumerated() {
            // 最初のタグ("全て")と最後のタグ("未グループ")は位置固定&ローカル管理のため、スルー
            if index == 0 && index == tags.count - 1 { continue }

            var tag = tag
            tag.oderIndex = index // 更新

            do {
                try await Tag.setData(.tags(teamId: teamId), docId: tag.id, data: tag)
            } catch {
                handleErrors([error])
            }
        }
    }

    /// タグが更新された際に使う。更新対象のタグが付与されている全てのアイテムを、新しいタグ名に変更する。
    /// 引数afterがnilの場合、対象アイテムのタグを"未グループ"に更新。
    func updateTargetItemsTag(before: Tag, after: Tag?, teamId: String?, items: [Item]) async {
        guard let teamId else { assertionFailure("teamId: nil"); return }

        let targetItems = items.filter { $0.tag == before.tagName }

        for item in targetItems {
            var item = item
            item.tag = after?.tagName ?? "未グループ" // タグを更新

            do {
                try await Item.setData(.items(teamId: teamId), docId: item.id, data: item)
            } catch {
                handleErrors([error])
            }
        }
    }

    func deleteTag(deleteTag: Tag, teamId: String, items: [Item]) async {
        do {
            // Firestore内のタグ削除
            try await Tag.deleteDocument(.tags(teamId: teamId), docId: deleteTag.id)

            // 削除タグが付与されていたアイテムを"未グループ"に更新
            await updateTargetItemsTag(before: deleteTag,
                                       after: nil,
                                       teamId: teamId,
                                       items: items)
        } catch {
            handleErrors([error])
        }
    }

    func removeListener() {
        tagListener?.remove()
    }

    deinit {
        print("<<<<<<<<<  TagViewModel_deinit  >>>>>>>>>")
        removeListener()
    }
}
