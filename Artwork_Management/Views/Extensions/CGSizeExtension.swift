//
//  CGSizeExtension.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/05.
//

import SwiftUI

extension CGSize: Hashable {
    public var hashValue: Int {
        return NSCoder.string(for: self).hashValue
    }
}
