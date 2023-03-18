//
//  ResizableSheetViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/18.
//

import SwiftUI
import ResizableSheet

class ResizableSheetViewModel: ObservableObject {
    
    @Published var showCart    : ResizableSheetState = .hidden
    @Published var showCommerce: ResizableSheetState = .hidden
}

