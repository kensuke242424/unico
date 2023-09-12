//
//  ResizableSheetViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/18.
//

import SwiftUI
import ResizableSheet
import FirebaseFirestore
import FirebaseFirestoreSwift

class CartViewModel: ObservableObject {
    
    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    
    @Published var showCart    : ResizableSheetState = .hidden
    @Published var showCommerce: ResizableSheetState = .hidden
    
    @Published var cartItems: [Item] = []
    
    @Published var doCommerce: Bool = false
    /// itemVM内のアイテムとcartItem内のアイテムで同期を取るために必要なアイテムインデックス。
    @Published var actionItemIndex: Int = 0
    @Published var resultCartAmount: Int = 0
    @Published var resultCartPrice: Int = 0

    /// カート内に選択アイテムを格納するメソッド。
    /// 新規追加アイテムの場合は、カート内にリスト要素を追加する。
    /// すでにカート内にアイテムが存在した場合、amountカウントを+1する。
    func addCartItem(item: Item) {
        let index = cartItems.firstIndex(where: { $0.id == item.id })
        
        if let index {
            cartItems[index].amount += 1
            resultCartPrice += cartItems[index].price
            resultCartAmount += 1
        } else {
            var item = item
            item.amount += 1
            resultCartPrice += item.price
            resultCartAmount += 1
            cartItems.append(item)
        }
    }
    /// カート内の各アイテムを精算し、アイテム情報を更新するメソッド。
    /// 同時に、アイテムの更新前・更新後二つのデータを入れたCompareItemモデルを配列で返す。
    /// CompareItemは通知の比較表示などで用いる。
    func updateCommerceItemsAndGetCompare(teamID: String) -> [CompareItem] {

        var compareItems: [CompareItem] = []

        guard let itemsRef = db?.collection("teams").document(teamID).collection("items") else {
            print("error: guard let tagsRef")
            return compareItems
        }

        for item in cartItems where item.amount != 0 {

            guard let itemID = item.id else {
                print("Error: 「\(item.name)」 guard let = item.id")
                continue
            }
            // 更新前・更新後を分けるためのアイテムコンテナを用意
            let defaultItem = item
            var updateItem = item

            updateItem.updateTime = Date()
            updateItem.sales += item.price * item.amount
            updateItem.inventory -= item.amount
            updateItem.totalAmount += item.amount
            updateItem.amount = 0

            do {
                try itemsRef.document(itemID).setData(from: updateItem)
                // Firestoreへの保存が成功すれば、更新比較アイテム情報CompareItemを返す
                let compareItem = CompareItem(id: defaultItem.id ?? "",
                                              before: defaultItem,
                                              after: updateItem)
                
                compareItems.append(compareItem)
            } catch {
                print("Error: 「\(item.name)」try reference.document(itemID).setData(from: item)")
            }
        }

        self.doCommerce = true
        return compareItems
    }
    /// カート内の総価格・総個数・選択アイテムを全てリセットするメソッド。
    func resetCart() {
        self.resultCartPrice = 0
        self.resultCartAmount = 0
        self.cartItems.removeAll()
    }
}

