//
//  PreloadViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/22.
//

import SwiftUI
import SDWebImageSwiftUI

class PreloadViewModel: ObservableObject {
    
    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Published var itemVM: ItemViewModel?
    
    @ViewBuilder
    func userCircleIcon(width: CGFloat, height: CGFloat) -> some View  {
        SDWebImageCircleIcon(imageURL: userVM.user?.iconURL,
                             width   : width,
                             height  : height)
    }
}
