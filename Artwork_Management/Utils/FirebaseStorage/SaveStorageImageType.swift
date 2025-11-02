//
//  SaveStorageImageType.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/11/20.
//

import Foundation.NSDate

enum SaveStorageImageType {
    case user(userId: String)
    case team(teamId: String)
    case item(teamId: String)
    case myBackground(userId: String)

    var storageFilePath: String {
        // 🔧 修正: URL安全なファイル名を生成（特殊文字を含まないタイムスタンプ）
        let timestamp = Self.generateSafeTimestamp()

        switch self {
        case .user(let userId):
            return "users/\(userId)/\(timestamp)"
        case .team(let teamId):
            return "teams/\(teamId)/\(timestamp)"
        case .item(let teamId):
            return "teams/\(teamId)/items/\(timestamp)"
        case .myBackground(let userId):
            return "users/\(userId)/myBackgrounds/\(timestamp)"
        }
    }

    /// URL安全なタイムスタンプ文字列を生成
    /// 形式: yyyyMMdd_HHmmss_UUID (例: 20251101_071435_A1B2C3D4)
    private static func generateSafeTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")

        let dateString = formatter.string(from: Date())
        let uuid = UUID().uuidString.prefix(8) // UUIDの最初の8文字を追加してユニーク性を保証

        return "\(dateString)_\(uuid)"
    }
}
