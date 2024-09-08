//
//  Log.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2024/09/08.
//

import Foundation
import os

public enum Logger {
    public static let standard: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.standard.rawValue
    )

    // 一般的な情報メッセージを記録
    public static func i(_ message: String) {
        Logger.standard.info("\(message, privacy: .public)")
    }

    // 詳細なデバッグ情報を記録
    public static func d(_ message: String) {
        Logger.standard.debug("\(message, privacy: .public)")
    }

    // エラーメッセージを記録
    public static func e(_ message: String) {
        Logger.standard.error("\(message, privacy: .public)")
    }
}

// MARK: - Privates

private enum LogCategory: String {
     case standard = "Standard"
}
