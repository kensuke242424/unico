//
//  UserViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI

class UserViewModel: ObservableObject {

    @Published var users: [User] = [User(name: "User_Name", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", photoImage: "", headerImage: "")]


        func convertImageToBase64(_ image: UIImage) -> String? {
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                print("Error: image.jpegData(compressionQuality: 1.0)")
                return nil
            }
            print("UIImage ⇨ jpegData変換成功: \(imageData)")
            return imageData.base64EncodedString()
        }

        func convertBase64ToImage(_ base64String: String) -> UIImage? {
            guard let imageData = Data(base64Encoded: base64String) else {
                print("Error: convertBase64ToImage")
                return nil
            }
            print("string ⇨ Data変換成功: \(imageData)")
            guard UIImage(data: imageData) != nil else {
                print("Error: UIImage(data: imageData)")
                return nil }

            return UIImage(data: imageData)
        }


//    func upDateUserPhotoData(userVM: UserViewModel, image: UIImage) {
//        print("=============  upDateUserDataメソッド実行  ===============")
//
//        guard let stringImage = image.toBase64String() else {
//            print("Error: image.toString()")
//            return
//        }
//
//        guard userVM.users.first != nil else {
//            print("Error: guard_self.parent.userVM.users.first")
//            return
//        }
//        // 取得した画像データのStringをユーザモデルに格納
//        userVM.users[0].photoImage = stringImage
//        print("ユーザ情報変更: \(userVM.users[0])")
//    }

}

struct TestUser {
    let testUser: User = User(name: "User_Name", address: "kennsuke242424@gmail.com", password: "ninnzinn2424", photoImage: "", headerImage: "")
}
