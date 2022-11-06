//
//  UserViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

class UserViewModel: ObservableObject {

    @Published var users: [User] = [User(name: "User_Name", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", photoURL: "")]

    func upDateUserPhotoData(userVM: UserViewModel, image: UIImage) {
        print("=============  upDateUserDataメソッド実行  ===============")

        guard let stringImage = image.toString() else {
            print("Error: image.toString()")
            return
        }

        guard userVM.users.first != nil else {
            print("Error: guard_self.parent.userVM.users.first")
            return
        }
        // 取得した画像データのStringをユーザモデルに格納
        userVM.users[0].photoURL = stringImage
        print("ユーザ情報変更: \(userVM.users[0])")
    }

}

struct TestUser {
    let testUser: User = User(name: "User_Name", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", photoURL: "")
}
