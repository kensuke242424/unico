//
//  Crop.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2024/09/08.
//

import Foundation

enum Crop: Equatable {
    case circle
    case rectangle
    case square
    case custom(CGSize)

    func name() -> String {
        switch self {
        case .circle:
            return "Circle"
        case .rectangle:
            return "Rectangle"
        case .square:
            return "Square"
        case let .custom(cGSize):
            return "Custom \(Int(cGSize.width))X\(Int(cGSize.height))"
        }
    }

    func size() -> CGSize {
        switch self {
        case .circle:
            return .init(width: 300, height: 300)
        case .rectangle:
            return .init(width: 300, height: 300)
        case .square:
            return .init(width: 300, height: 300)
        case .custom(let cgSize):
            return cgSize
        }
    }
}
