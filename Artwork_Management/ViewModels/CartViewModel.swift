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

class CartViewModel: ObservableObject, FirebaseErrorHandling {

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name
    
    @Published var showCart    : ResizableSheetState = .hidden
    @Published var showCommerce: ResizableSheetState = .hidden
    
    @Published var cartItems: [Item] = []
    
    @Published var doCommerce: Bool = false
    /// itemVM内のアイテムとcartItem内のアイテムで同期を取るために必要なアイテムインデックス。
    @Published var actionItemIndex: Int = 0
    @Published var resultCartAmount: Int = 0
    @Published var resultCartPrice: Int = 0

    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

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
    
    func updateCommerceItems(items: [Item], teamId: String) async {

        var compareItems: [CompareItem] = []

        for item in items where item.amount != 0 {
            let updatedItem = commerceItemCalculate(item)

            do {
                try await Item.setData(.items(teamId: teamId), docId: item.id, data: updatedItem)
            } catch {
                handleErrors([error])
            }
        }
    }

    /// 在庫処理が実行されたアイテムのパラメータを更新し返すメソッド。
    private func commerceItemCalculate(_ item: Item) -> Item {
        var item = item

        item.updateTime = Date()
        item.sales += item.price * item.amount
        item.inventory -= item.amount
        item.totalAmount += item.amount
        item.amount = 0

        return item
    }

    /// カート内の各アイテムを精算し、アイテム情報を更新するメソッド。
    /// 同時に、アイテムの更新前・更新後二つのデータを入れたCompareItemモデルを配列で返す。
    /// CompareItemは通知の比較表示などで用いる。
    func updateCommerceItemsAndGetCompare(teamId: String) async -> [CompareItem] {

        var compareItems: [CompareItem] = []

        for item in cartItems where item.amount != 0 {

            // 更新前・更新後を分けるためのアイテムコンテナを用意
            let defaultItem = item
            var updatedItem = commerceItemCalculate(item)

            do {
                try await Item.setData(.items(teamId: teamId), docId: item.id, data: updatedItem)
                // Firestoreへの保存が成功すれば、更新比較アイテム情報CompareItemを返す
                let compareItem = CompareItem(id: defaultItem.id,
                                              before: defaultItem,
                                              after: updatedItem)
                compareItems.append(compareItem)

            } catch {
                handleErrors([error])
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

