//
//  UserViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

class UserViewModel: ObservableObject {

    @Published var users: [User] = [User(name: "User_Name", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", iconImage: "", headerImage: "")]

    var headerImage: UIImage? {
        return users[0].headerImage.toImage()
    }

}

struct TestUser {
    let testUser: User = User(name: "User_Name", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", iconImage: "", headerImage: "")
}
