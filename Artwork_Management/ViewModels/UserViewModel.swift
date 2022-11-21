//
//  UserViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/06.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  UserViewModel_init  >>>>>>>>>")
    }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    @Published var users: [User] = []
    var uid = ""
    var signInError = ""
    var signUpError = ""

    func signInAndGetUid(email: String, password: String) async -> String? {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let uid = result.user.uid
            print("signInAndGetUid成功_uid：\(uid)")
            return uid
        } catch {
             let errorCode = AuthErrorCode.Code(rawValue: error._code)
            switch errorCode {
            case .invalidEmail:
                signInError = "メールアドレスの形式が正しくありません"
            case .emailAlreadyInUse:
                signInError = "このメールアドレスは既に登録されています"
            case .weakPassword:
                signInError = "パスワードは６文字以上で入力してください"
            default:
                signInError = "予期せぬエラーが発生しました。"
            }
            return nil
        }
    }

    func signUpAndGetUid(email: String, password: String) async -> String? {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            print("signUpAndGetUid成功_uid：\(uid)")
            return uid
        } catch {
            let errorCode = AuthErrorCode.Code(rawValue: error._code)

            switch errorCode {
            case .invalidEmail:
                signUpError = "メールアドレスの形式が正しくありません"
            case .emailAlreadyInUse:
                signUpError = "このメールアドレスは既に登録されています"
            case .weakPassword:
                signUpError = "パスワードは６文字以上で入力してください"
            default:
                signUpError = "予期せぬエラーが発生しました。"
            }
            return nil
        }
    }

    func addUser(userData: User) {

        print("addUser実行")

        guard let itemsRef = db?.collection("users") else {
            print("error: guard let tagsRef")
            return
        }

        do {
            _ = try itemsRef.addDocument(from: userData)
        } catch {
            print("Error: try db!.collection(collectionID).addDocument(from: itemData)")
        }
        print("addUser完了")
    }
}

struct TestUser {
    let testUser: User = User(id: "sampleUserID(uid)", name: "SampleUser", address: "kennsuke242424@gmail.com",
                              password: "ninnzinn2424", iconURL: nil, iconPath: nil, joins: [])
}
