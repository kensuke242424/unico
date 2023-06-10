//
//  BackgroundViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/10.
//

import SwiftUI

class BackgroundViewModel: ObservableObject {
    /// バックグラウンドを管理するプロパティ
    @Published var teamBackground: URL?
    @Published var captureBackgroundImage: UIImage?
    @Published var showPickerView: Bool = false
    @Published var showSelectBackground: Bool = false
    @Published var checkBackgroundToggle: Bool = false
    @Published var checkBackgroundAnimation: Bool = false
    @Published var selectBackgroundCategory: TeamBackgroundContents = .technology
    @Published var selectedBackgroundImage: UIImage?
}
