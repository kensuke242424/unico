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

    var groupID: String = "7gm2urHDCdZGCV9pX9ef"

    var tagListener: ListenerRegistration?
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    @Published var tags: [Tag] = []

    func fetchTag(groupID: String) async {

        print("fetchTag実行")

        guard let tagsRef = db?.collection("groups/\(groupID)/tags") else { return }

        tagListener = tagsRef.addSnapshotListener { (snaps, _) in

            guard let documents = snaps?.documents else {
                print("Error: guard let documents = snap?.documents")
                return
            }

            self.tags = documents.compactMap { (snap) -> Tag? in

                do {
                    return try snap.data(as: Tag.self, with: .estimate)

                    // 先頭と末尾にタグを追加
                } catch {
                    print("Error: try snap.data(as: Tag.self, with: .estimate)")
                    return Tag(oderIndex: 1, tagName: "???", tagColor: "灰")
                }
            }

            // firestoreからタグのfetch後、ローカル環境にALLと未グループを追加
            self.tags.insert(Tag(oderIndex: 0, tagName: "ALL", tagColor: "灰"), at: 0)
            self.tags.append(Tag(oderIndex: self.tags.count - 1, tagName: "未グループ", tagColor: "灰"))

            print("fetchTag完了")
            print(self.tags)

        }
    }

    func addTag(tagData: Tag, groupID: String) {
        guard let tagsRef = db?.collection("groups/\(groupID)/tags") else { return }
        do {
            _ = try tagsRef.addDocument(from: tagData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
        }
    }

    func updateTagData(updateData: Tag, defaultData: Tag) {

        guard let defaultDataID = defaultData.id else { return }
        guard let updateTagRef = db?.collection("groups/\(groupID)/tags").document(defaultDataID) else { return }
        guard let updateItemsRef = db?.collection("groups/\(groupID)/items") else { return }

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
                    var itemID = document.documentID
                    updateItemsRef.document(itemID).updateData(["tag": updateData.tagName])
                }
            }
        }

    }

    func filterTagsData(selectTagName: String) -> UsedColor {

        let filterTag = tags.filter { $0.tagName == selectTagName }

        if let filterTag = filterTag.first {

            switch filterTag.tagColor {
            case "赤": return .red
            case "青": return .blue
            case "黄": return .yellow
            case "緑": return .green
            default:
                return .gray
            }

        } else {
            return.gray
        }
    } // func castStringIntoColor

    deinit {
        print("<<<<<<<<<  TagViewModel_deinit  >>>>>>>>>")
        tagListener?.remove()
    }

}
