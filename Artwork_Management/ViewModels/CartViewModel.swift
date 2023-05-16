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
    @Published var actionItemIndex: Int = 0
    @Published var resultCartAmount: Int = 0
    @Published var resultCartPrice: Int = 0
    
    func addCartItem(item: Item) {
        
        let index = cartItems.firstIndex(where: { $0.id == item.id })
        print("cartItems_index: \(index)")
        
        if let index {
            print("追加アイテムはカート内に存在する")
            cartItems[index].amount += 1
            resultCartPrice += cartItems[index].price
            resultCartAmount += 1
        } else {
            print("追加アイテムはカート内に存在しない")
            var item = item
            item.amount += 1
            resultCartPrice += item.price
            resultCartAmount += 1
            cartItems.append(item)
        }
    }
    
    func updateCommerseItems(teamID: String) {

        print("updateCommerse実行")

        guard let itemsRef = db?.collection("teams").document(teamID).collection("items") else {
            print("error: guard let tagsRef")
            return
        }

        for item in cartItems where item.amount != 0 {

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
        resetCart()
        self.doCommerce = true
    }
    
    func resetCart() {
        self.resultCartPrice = 0
        self.resultCartAmount = 0
        self.cartItems.removeAll()
    }
}

