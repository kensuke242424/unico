//
//  TimesView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/16.
//

import SwiftUI

struct InputTime {

    var nowDate =  Date()
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var time: String {
        let formatter = DateFormatter()
        formatter.setTemplate(.time, .enUS)
        return formatter.string(from: nowDate)
    }
    var week: String {
        let formatter = DateFormatter()
        formatter.setTemplate(.usWeek, .enUS)
        return formatter.string(from: nowDate)
    }
    var dateStyle: String {
        let formatter = DateFormatter()
        formatter.setTemplate(.usMonthDay, .enUS)
        return formatter.string(from: nowDate)
    }
}

