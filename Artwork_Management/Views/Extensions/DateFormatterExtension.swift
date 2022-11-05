//
//  DateFormatterExtension.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/05.
//

import Foundation

extension DateFormatter {

    // テンプレートの定義(例)
    enum Template: String {
        case date = "yMd"     // 2017/1/1
        case time = "Hms"     // 12:39:22
        case full = "yMdkHms" // 2017/1/1 12:39:22
        case onlyHour = "k"   // 17時
        case era = "GG"       // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case usWeek = "EEE" // Tue
        case usMonthDay = "MMMM.d" // Jun 10
    }

    func setTemplate(_ template: Template) {
            // optionsは拡張用の引数だが使用されていないため常に0
            dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: .current)
        }
}
