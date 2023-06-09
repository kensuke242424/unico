//
//  ProgressViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/07.
//

import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var showLoading: Bool = false
    @Published var showCubesProgress: Bool = false
}
