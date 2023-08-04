//
//  NotificationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/03.
//

import SwiftUI

class LocalNotificationViewModel: ObservableObject {

    init() { print("<<<<<<<<<  NotificationViewModel_init  >>>>>>>>>") }

    @Published var localNotifications: [LocalNotifyFrame] = []

    func setLocalNotification(type: LocalNotificationType) {
        localNotifications.append(
            LocalNotifyFrame(type: type.self,
                       message: type.message,
                       exitTime: type.exitTime)
        )
    }
}
