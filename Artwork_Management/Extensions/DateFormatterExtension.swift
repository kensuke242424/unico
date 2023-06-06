//
//  DateFormatterExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/08.
//

import Foundation

extension DateFormatter {

    enum SelectLocale: String {
        case enUS = "en_US"
        case jaJP = "ja_JP"
    }

    // テンプレートの定義(例)
    // Hours(時), minutes(分), seconds(秒)
    /// H = 24時間表記、　h = 12時間表記
    enum Template: String {
        case ampm = "a"       // PM,午後
        case date = "yMd"     // 2017/1/1
        case Hms = "Hms"     // 12:39:22
        case Hm = "Hm"     // 17:39(24時間表記)
        case hm = "hm"     // 11:39(12時間表記)
        
        case full = "yMdkHms" // 2017/1/1 12:39:22
        case onlyHour = "k"   // 17時
        case era = "GG"       // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case usWeek = "EEE" // Tue
        case usMonthDay = "MMMM.d" // Jun 10
    }

    func setTemplate(_ template: Template, _ locale: SelectLocale) {
            // optionsは拡張用の引数だが使用されていないため常に0
        dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: Locale(identifier: locale.rawValue))
        }
}
