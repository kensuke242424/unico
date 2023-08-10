//
//  AnyShape.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/08/11.
//

import SwiftUI

/// メンバ変数としてShapeを定義する際に使う構造体
public struct AnyShape: Shape {
    public var make: (CGRect, inout Path) -> ()

    public init(_ make: @escaping (CGRect, inout Path) -> ()) {
        self.make = make
    }

    public init<S: Shape>(_ shape: S) {
        self.make = { rect, path in
            path = shape.path(in: rect)
        }
    }

    public func path(in rect: CGRect) -> Path {
        return Path { [make] in make(rect, &$0) }
    }
}
