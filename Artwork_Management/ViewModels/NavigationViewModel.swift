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

enum SystemAccountPath {
    case root, defaultEmailCheck, updateEmail, successUpdateEmail, deleteAccount, deletedData
}

class NavigationViewModel: ObservableObject {
    
    @Published var path = NavigationPath()
    
}
