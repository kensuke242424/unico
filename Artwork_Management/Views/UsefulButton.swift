//
//  UsefulButtonView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/06.
//

import SwiftUI

struct UsefulButton: View {

    @Binding var tabIndex: Int

    var body: some View {
        Button {

            switch tabIndex {
            case 0:
                print("ホーム画面でのボタン処理")
            case 1:
                print("ストック画面でのボタン処理")
            case 2:
                print("売上画面でのボタン処理")
            case 3:
                print("システム画面でのボタン処理")
            default:
                print("default")
            }

        } label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 78)
                .blur(radius: 2)
                .shadow(radius: 5, x: 7, y: 10)
                .overlay {
                    Image(systemName: "shippingbox.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .shadow(radius: 10, x: 3, y: 5)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .offset(x: 10, y: -10)
                        } // overlay
                } // overlay
        } // Button
        .offset(x: UIScreen.main.bounds.width / 3 - 5,
                y: UIScreen.main.bounds.height / 3 - 20)
    }
}

struct UsefulButton_Previews: PreviewProvider {
    static var previews: some View {
        UsefulButton(tabIndex: .constant(2))
    }
}
