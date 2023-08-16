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
    /// 渡されたDate値と現在の時間とを比べて、差分によってどれぐらい前かをStringで出力するメソッド。
    /// 主に通知などのビューでの時間差分表示で使う。
    func getNowTimeDifference() -> String {
        let dayValue = (60 * 60 * 24)
        let hoursValue = (60 * 60)
        let minuteValue = 60
        let nowValue = Int(Date.now.timeIntervalSince1970)
        let subjectValue = Int(self.timeIntervalSince1970)
        var differenceValue: Int {
            return nowValue - subjectValue
        }

        if differenceValue <= minuteValue {
            return "今"

        } else if differenceValue >= minuteValue {
            let divisionValue = floor(Double(differenceValue / minuteValue))
            return "\(String(Int(divisionValue)))分前"

        } else if differenceValue >= hoursValue {
            let divisionValue = floor(Double(differenceValue / hoursValue))
            return "\(String(Int(divisionValue)))時間前"

        } else if differenceValue >= dayValue {
            let divisionValue = floor(Double(differenceValue / dayValue))
            return "\(String(Int(divisionValue)))日前"
        } else {
            return "???"
        }
    }
}
