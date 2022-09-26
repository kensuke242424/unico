//
//  SystemList.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/09/25.
//

import SwiftUI

struct SystemListView: View {
    var body: some View {

        List {

            Section {
                ForEach(1...3, id: \.self) { num in
                    Text("設定\(num)")
                }
            } header: {
                Text("Account")
                    .font(.title2)
            }

            Section {
                ForEach(1...3, id: \.self) { num in
                    Text("設定\(num)")
                }
            } header: {
                Text("System")
                    .font(.title2)
            }

            Section {
                ForEach(1...3, id: \.self) { num in
                    Text("設定\(num)")
                }
            } header: {
                Text("Infomation")
                    .font(.title2)
            }

        } // List
    } // body
} // View

struct SystemList_Previews: PreviewProvider {
    static var previews: some View {
        SystemListView()
    }
}
