//
//  TagViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/12.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class TagViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  TagViewModel_init  >>>>>>>>>")
    }

    var tagListener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    @Published var tags: [Tag] = []
    @Published var showEdit: Bool = false

    func fetchTag(teamID: String) async {

        print("fetchTag実行")

        guard let tagsRef = db?.collection("teams").document(teamID).collection("tags") else {
            return
        }

        tagListener = tagsRef.addSnapshotListener { (snaps, error) in

            if let error = error {
                print(error)
                return
            }

            guard let documents = snaps?.documents else {
                print("Error: guard let documents = snap?.documents")
                return
            }

            withAnimation {
            self.tags = documents.compactMap { (snap) -> Tag? in

                    do {
                        return try snap.data(as: Tag.self, with: .estimate)
                    } catch {
                        print("Error: try snap.data(as: Tag.self, with: .estimate)")
                        return Tag(oderIndex: 1, tagName: "???", tagColor: .gray)
                    }
                }
            }

            self.tags.sort { $0.oderIndex < $1.oderIndex }

            // firestoreからタグのfetch後、ローカル環境にALLと未グループを追加
            self.tags.insert(Tag(oderIndex: 0, tagName: "全て", tagColor: .gray), at: 0)
            self.tags.append(Tag(oderIndex: self.tags.count, tagName: "未グループ", tagColor: .gray))
        }
        print("fetchTag終了")
    }

    func addTag(tagData: Tag, teamID: String) {
        guard let tagsRef = db?.collection("teams/\(teamID)/tags") else { return }
        do {
            _ = try tagsRef.addDocument(from: tagData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
        }
    }

    func updateOderTagIndex(teamID: String) {

        guard let tagsRef = db?.collection("teams/\(teamID)/tags") else { return }

        for (index, tag) in tags.enumerated() {
            if index == 0 && index == tags.count - 1 { continue }
            guard let tagID = tag.id else { continue }
            tagsRef.document(tagID).updateData(["oderIndex": index])
            print("\(tags[index].tagName).oderIndex: \(index)")
        }
    }

    func updateTagData(updateData: Tag, defaultData: Tag, teamID: String) {

        guard let defaultDataID = defaultData.id else { return }
        guard let updateTagRef = db?.collection("teams/\(teamID)/tags").document(defaultDataID) else { return }
        guard let updateItemsRef = db?.collection("teams/\(teamID)/items") else { return }

        do {
            try updateTagRef.setData(from: updateData)
        } catch {
            print("Error: try updateTagRef.setData(from: updateData)")
            return
        }

        // 更新したタグに紐づいていたアイテムをwhereFieldで検出し、まとめて更新
        updateItemsRef.whereField("tag", isEqualTo: defaultData.tagName).getDocuments { (snaps, error) in

            if let error = error {
                print("Error: \(error)")
            } else {
                guard let snaps = snaps else { return }

                for document in snaps.documents {
                    let itemID = document.documentID
                    updateItemsRef.document(itemID).updateData(["tag": updateData.tagName])
                }
            }
        }

    }
    /// タグの削除と同時に、紐づいていたアイテムのタグを「未グループ」に更新するメソッド
    func deleteTag(deleteTag: Tag, teamID: String) {

        guard let tagID = deleteTag.id else { return }
        guard let tagRef = db?.collection("teams/\(teamID)/tags").document(tagID) else { return }
        guard let itemsRef = db?.collection("teams/\(teamID)/items") else { return }

        itemsRef.whereField("tag", isEqualTo: deleteTag.tagName).getDocuments { (snaps, error) in

            if let error = error {
                print("Error: \(error)")
            } else {
                guard let snaps = snaps else { return }
                for document in snaps.documents {
                    let itemID = document.documentID
                    // タグの削除と、紐ずくアイテムのタグ解除
                    itemsRef.document(itemID).updateData(["tag": self.tags.last!.tagName])
                }
                tagRef.delete()
            }
        }
    }

    deinit {
        print("<<<<<<<<<  TagViewModel_deinit  >>>>>>>>>")
        tagListener?.remove()
    }

}
