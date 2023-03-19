//
//  ShowItemViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/19.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI

struct ShowItem: Identifiable {

    @DocumentID var id: String?
    @ServerTimestamp var createTime: Timestamp?
    @ServerTimestamp var updateTime: Timestamp?
    var tag: String?
    var name: String?
    var author: String?
    var detail: String?
    var image: WebImage?
    var cost: Int?
    var price: Int?
    var amount: Int?
    var sales: Int?
    var inventory: Int?
    var totalAmount: Int?
    var totalInventory: Int?
}
