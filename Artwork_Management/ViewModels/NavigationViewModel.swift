//
//  NavigationViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/24.
//

import SwiftUI

enum EditItemPath {
    case create, edit
}

enum SystemPath {
    case root
}

class NavigationViewModel: ObservableObject {
    
    @Published var path = NavigationPath()
    
}
