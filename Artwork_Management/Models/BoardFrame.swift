//
//  BoardFrame.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

struct BoardFrame: Identifiable, Equatable, Hashable {
    var id: UUID = .init()
    var image: UIImage?
    var imageURL: URL?
    var type: NotificationType
    var message: String
    var color: Color
    var waitTime: CGFloat
}

extension BoardFrame {
    static func == (lhs: BoardFrame, rhs: BoardFrame) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
            return hasher.combine(id)
    }
}
