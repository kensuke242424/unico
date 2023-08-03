//
//  NotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

class NotificationViewModel: ObservableObject {

    @Published var boardFrames: [BoardFrame] = []

    func setNotify(type: NotificationType) {
        boardFrames.append(
            BoardFrame(type: type.self,
                       message: type.message,
                       imageURL: type.imageURL,
                       color: type.color,
                       exitTime: type.waitTime)
        )
    }
}
