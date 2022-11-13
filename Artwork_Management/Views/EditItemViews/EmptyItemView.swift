//
//  EmptyItemView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/13.
//

import SwiftUI

struct EmptyItemView: View {

    @Binding var inputHome: InputHome
    let text: String

    var body: some View {
        VStack {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white).opacity(0.6)

            Button {
                inputHome.editItemStatus = .create
                inputHome.isPresentedEditItem.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.black.opacity(0.2))
                    .frame(width: 80, height: 30)
                    .overlay {
                        HStack {
                            Image(systemName: "shippingbox.fill")
                            Text("追加")
                        }
                    }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}
