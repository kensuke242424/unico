//
//  NotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

class MomentLogViewModel: ObservableObject {

    init() { print("<<<<<<<<<  NotificationViewModel_init  >>>>>>>>>") }

    @Published var localNotifications: [MomentLog] = []

    func setLog(type: LocalNotificationType) {
        localNotifications.append(
            MomentLog(type: type.self,
                       message: type.message,
                       exitTime: type.exitTime)
        )
    }
}
