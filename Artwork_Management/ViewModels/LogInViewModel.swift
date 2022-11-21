//
//  LogInViewModel.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2022/11/21.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class LogInViewModel: ObservableObject {

    init() {
        print("<<<<<<<<<  LogInViewModel_init  >>>>>>>>>")
    }

    var db: Firestore? = Firestore.firestore() // swiftlint:disable:this identifier_name

    var logInErrorMessage: String = ""

    func signIn(email: String, password: String) async -> Bool {

        logInErrorMessage = ""

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let uid = result.user.uid
            print("signIn成功_uid：\(uid)")
            return true
        } catch {
             let errorCode = AuthErrorCode.Code(rawValue: error._code)
            switch errorCode {
            case .invalidEmail:
                logInErrorMessage = "メールアドレスの形式が正しくありません"
            case .emailAlreadyInUse:
                logInErrorMessage = "このメールアドレスは既に登録されています"
            case .weakPassword:
                logInErrorMessage = "パスワードは６文字以上で入力してください"
            default:
                logInErrorMessage = "予期せぬエラーが発生しました。"
            }
            return false
        }
    }

    func signUp(email: String, password: String) async -> Bool {

        logInErrorMessage = ""

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            print("signUp成功_uid：\(uid)")
            return true
        } catch {
            let errorCode = AuthErrorCode.Code(rawValue: error._code)

            switch errorCode {
            case .invalidEmail:
                logInErrorMessage = "メールアドレスの形式が正しくありません"
            case .emailAlreadyInUse:
                logInErrorMessage = "このメールアドレスは既に登録されています"
            case .weakPassword:
                logInErrorMessage = "パスワードは６文字以上で入力してください"
            default:
                logInErrorMessage = "予期せぬエラーが発生しました。"
            }
            return false
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

    func uploadImage(_ image: UIImage) async -> (url: URL?, filePath: String?) {

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "images/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func deleteImage(path: String) async {

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("imageRef.delete succsess!")
            }
        }
    }
}
