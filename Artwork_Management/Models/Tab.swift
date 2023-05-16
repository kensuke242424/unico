//
//  Tab.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

/// 各タブの選択を管理する
enum Tab: String, CaseIterable {
    case home = "Home"
    case item = "Item"
    
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
    
    var count: Int {
        return Tab.allCases.count
    }
}
