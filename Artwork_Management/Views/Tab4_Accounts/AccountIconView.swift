//
//  AccountIcon.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/25.
//

import SwiftUI

struct AccountIconView: View {
    var body: some View {

        VStack {

            Text("Account_Name")
                .font(.title)

            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 200, height: 200)

        } // VStack
    } // body
} // View

struct AccountIcon_Previews: PreviewProvider {
    static var previews: some View {
        AccountIconView()
    }
}
