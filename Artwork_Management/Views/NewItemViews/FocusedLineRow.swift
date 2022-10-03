//
//  FocusedLineRow.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/03.
//

import SwiftUI

struct FocusedLineRow: View {

    let select: Bool

    var body: some View {

        Rectangle()
            .frame(height: select ? 2 : 1)
            .foregroundColor(select ? .blue : .gray)
            .opacity(select ? 0.4 : 0.3)
            .shadow(radius: select ? 2 : 0,
                    x: select ? 1 : 0)
    }
}

struct FocusedLineRow_Previews: PreviewProvider {
    static var previews: some View {
        FocusedLineRow(select: true)
    }
}
