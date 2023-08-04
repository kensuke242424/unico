//
//  LocalNotifyFrame.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import Foundation

/// ユーザーのローカルに通知される通知ボードのフレーム。
/// このデータはFirestoreとの通信を介さない。
struct LocalNotifyFrame: Identifiable, Hashable {
    var id: UUID = .init()
    var type: LocalNotificationType
    var message: String
    var exitTime: CGFloat
}
