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
}
