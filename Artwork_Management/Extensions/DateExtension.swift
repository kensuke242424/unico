//
//  DateExtension.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/04.
//

import Foundation

/// Dateのデータ表示をカレンとロケールに合わせる。
extension Date {
    func toStringWithCurrentLocale() -> String {

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: self)
    }
    /// Dateの時間を１時間ずらす。主に初期サンプルアイテム挿入時に使う。
    /// (更新キャンセル時にcreateTimeの差分を用いるため)
    func plusOneHour() -> Date {
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: 1, to: self)
        return modifiedDate ?? Date()
    }
}
