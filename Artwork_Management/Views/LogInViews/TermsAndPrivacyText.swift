//
//  TermsAndPrivacyView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/20.
//

import SwiftUI

struct TermsAndPrivacyView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.gradient)

            TermsAndPrivacyText()
                .padding(8)
        }
        .frame(width: getRect().width - 80, height: 60)
    }
}

struct TermsAndPrivacyText: UIViewRepresentable {
    /// 属性付きのテキスト
    var attributedText: NSAttributedString {
        let baseString = "利用規約とプライバシーポリシーをご確認の上、先に進んでください。"
        let attributedString = NSMutableAttributedString(string: baseString)

        // 文字色
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                      value: UIColor.white,
//                                      range: NSMakeRange(0, baseString.count))
        // 利用規約のリンク
        attributedString.addAttribute(.link,
                                      value: "https://www.google.co.jp/",
                                      range: NSString(string: baseString).range(of: "利用規約"))
        // プライバシーポリシーのリンク
        attributedString.addAttribute(.link,
                                      value: "https://www.google.co.jp/",
                                      range: NSString(string: baseString).range(of: "プライバシーポリシー"))
        return attributedString
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.textColor = UIColor.gray
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = true
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.attributedText = attributedText
    }
}
