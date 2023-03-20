//
//  FocusedLineRow.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/03.
//

import SwiftUI

struct FocusedLineRow: View {

    let select: Bool
    let width: CGFloat
    @State private var lineAnimation: CGFloat = 0

    var body: some View {

        Rectangle()
            .frame(height: select ? 2 : 1)
            .foregroundColor(.gray)
            .opacity(0.4)

            .overlay {
                HStack {
                    Rectangle()
                        .frame(width: lineAnimation, alignment: .leading)
                        .foregroundColor(.blue)
                        .shadow(radius: select ? 2 : 0, x: select ? 1 : 0)
                        .shadow(color: .white.opacity(0.5),
                                radius: select ? 7 : 0,
                                x: select ? 1 : 0)
                        .shadow(color: .white.opacity(0.5),
                                radius: select ? 7 : 0,
                                x: select ? 1 : 0)
                    
                    Spacer(minLength: 0)
                }
                
            }
        
            .onChange(of: select) { newValue in
                if newValue == true {
                    withAnimation(.spring(response: 0.2)) {
                        lineAnimation = width
                    }
                } else {
                    lineAnimation = 0
                }
            }
    }
}

struct FocusedLineRow_Previews: PreviewProvider {
    static var previews: some View {
        FocusedLineRow(select: true, width: 300)
    }
}
