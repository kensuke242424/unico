//
//  HashableExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/22.
//

import Foundation

extension Hashable where Self : CaseIterable {
    var index: Self.AllCases.Index {
        return type(of: self).allCases.firstIndex(of: self)!
    }
}
