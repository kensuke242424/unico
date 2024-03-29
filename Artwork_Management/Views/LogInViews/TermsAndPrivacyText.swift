//
//  TermsAndPrivacyView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/05/20.
//

import SwiftUI

struct TermsAndPrivacyView: View {
    @Binding var isCheck: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.gradient)

            HStack {

                Rectangle()
                    .fill(isCheck ? .green : .white)
                    .frame(width: 15, height: 15)
                    .overlay {
                        if isCheck {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .offset(y: -1)
                        }
                    }
                    .overlay {
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                            .frame(width: 15, height: 15)
                    }
                    .onTapGesture(perform: {
                        isCheck.toggle()
                        hapticSuccessNotification()
                    })
                    .padding(5)

                TermsAndPrivacyText()

            }
            .padding(8)
        }
        .frame(width: getRect().width - 80, height: 60)
    }
}

struct TermsAndPrivacyText: UIViewRepresentable {
    /// 属性付きのテキスト
    var attributedText: NSAttributedString {
        let baseString = "利用規約とプライバシーポリシーを確認した上で、規約に同意します。"
        let attributedString = NSMutableAttributedString(string: baseString)

        // 文字色
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
//                                      value: UIColor.white,
//                                      range: NSMakeRange(0, baseString.count))
        // 利用規約のリンク
        attributedString.addAttribute(.link,
                                      value: "https://unicoapp.wixsite.com/mysite/%E5%88%A9%E7%94%A8%E8%A6%8F%E7%B4%84",
                                      range: NSString(string: baseString).range(of: "利用規約"))
        // プライバシーポリシーのリンク
        attributedString.addAttribute(.link,
                                      value: "https://unicoapp.wixsite.com/mysite/%E3%83%97%E3%83%A9%E3%82%A4%E3%83%90%E3%82%B7%E3%83%BC%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC",
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
