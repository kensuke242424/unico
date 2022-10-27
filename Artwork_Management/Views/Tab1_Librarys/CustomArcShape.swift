//
//  CustomArcShape.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/10/27.
//

import SwiftUI

struct CustomArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            let pt1 =  CGPoint(x: 0, y: 70)
            let pt2 =  CGPoint(x: 0, y: rect.height)
            let pt3 =  CGPoint(x: rect.width * 0.98, y: rect.height)
            let pt4 =  CGPoint(x: rect.width * 0.2, y: 0)

            path.move(to: pt1)
            path.addArc(tangent1End: pt1, tangent2End: pt2, radius: 0)
            path.addArc(tangent1End: pt2, tangent2End: pt3, radius: 0)
            path.addArc(tangent1End: pt3, tangent2End: pt4, radius: 0)
            path.addArc(tangent1End: pt4, tangent2End: pt1, radius: rect.height / 1.5)
        }
    }
}

struct CustomArcShape_Previews: PreviewProvider {
    static var previews: some View {
        CustomArcShape()
    }
}
