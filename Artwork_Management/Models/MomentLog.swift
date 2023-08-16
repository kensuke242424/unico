//
//  LocalNotifyFrame.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import Foundation

/// ユーザーのローカルに通知される通知ボードのフレーム。
/// このデータはFirestoreとの通信を介さず、ローカル内で追加と削除が実行される。
struct MomentLog: Identifiable, Hashable {
    var id: UUID = .init()
    var type: LocalNotificationType
    var message: String
    var exitTime: CGFloat
}
