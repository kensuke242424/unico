//
//  BackgroundViewModel.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/10.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class BackgroundViewModel: ObservableObject {

    var db: Firestore? = Firestore.firestore()

    /// カテゴリ指定によって取得した背景サンプルデータが格納されるプロパティ
    @Published var categoryBackgrounds: [Background] = []

    /// サインアップ画面において、ユーザーが自身の写真ライブラリから選択した画像を一時的に保持するプロパティ。
    /// ユーザーデータの作成時に、自身の背景画像保管データテーブルに渡される。
    @Published var pickMyBackgroundsAtSignUp: [Background] = []

    /// バックグラウンドを管理するプロパティ
    @Published var teamBackground: URL?
    @Published var croppedUIImage: UIImage?
    @Published var selectCategory: BackgroundCategory = .music
    @Published var selectBackground: Background?
    @Published var deleteTarget: Background?

    /// 背景編集モード関連のビューステートを管理するプロパティ
    @Published var showPicker: Bool = false
    @Published var showEdit: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var checkModeToggle: Bool = false
    @Published var checkMode: Bool = false
    @Published var savingWait: Bool = false

    func resetSelectBackgroundImages() async {
        withAnimation(.easeInOut(duration: 0.5)) {
            DispatchQueue.main.async {
                withAnimation {
                    self.categoryBackgrounds = []
                }
            }
        }
    }

    /// ユーザーがタグ「original」を選択した際に実行するメソッド。
    /// userドキュメントから取得した画像データを背景管理プロパティに渡していく
    func appendMyBackgrounds(images backgroundImages: [Background]) {
        for myImage in backgroundImages {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.categoryBackgrounds.append(myImage)
                }
            }
        }
    }

    func fetchCategoryBackgroundImage(category: String) async {

        let containerID = "\(category)Backgrounds"
        let upperCasedID = containerID.uppercased()
        let lowercasedID = containerID.lowercased()

        guard let categoryBackgroundRefs = db?.collection("backgrounds")
            .document(upperCasedID)
            .collection(lowercasedID) else {
            return
        }

        print("背景データ取得開始")

        do {
            let snapshot = try await categoryBackgroundRefs.getDocuments()
            let documents = snapshot.documents

            let fetchImages = documents.compactMap { document in
                do {
                    let fetchImage = try document.data(as: Background.self)
                    return fetchImage
                } catch {
                    print("背景データの取得失敗")
                    return nil
                }
            }

            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.categoryBackgrounds = fetchImages
                }
            }
        } catch {
            print("背景データの取得失敗")
        }
    }
    /// サインアップ時に、ユーザーが写真フォルダから選択した画像をFirestorageに保存するメソッド。
    func uploadUserBackgroundAtSignUp(_ image: UIImage?) async -> (url: URL?, filePath: String?) {

        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "users/\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageData)
            let url = try await imageRef.downloadURL()

            return (url: url, filePath: filePath)
        } catch {
            return (url: nil, filePath: nil)
        }
    }

    func resizeUIImage(image: UIImage?) -> UIImage? {

        let width: CGFloat = UIScreen.main.bounds.width

        if let originalImage = image {
            // オリジナル画像のサイズからアスペクト比を計算
            let aspectScale = originalImage.size.height / originalImage.size.width

            // widthからアスペクト比を元にリサイズ後のサイズを取得
            let resizedSize = CGSize(width: width * 3, height: width * Double(aspectScale) * 3)

            // リサイズ後のUIImageを生成して返却
            UIGraphicsBeginImageContext(resizedSize)
            originalImage.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resizedImage
        } else {
            return nil
        }
    }

    func deleteBackground(path: String?) {

        guard let path = path else { return }

        let storage = Storage.storage()
        let reference = storage.reference()
        let imageRef = reference.child(path)

        imageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("Backgroundの削除完了")
            }
        }
    }
}

/* 
 MEMO:
 以下の拡張は、開発者がFirebase Storageにサンプル画像データ群（約１００枚）を、
 リサイズ&保存する用に作成したロジックである。アプリ内では使用しない。
 */
private extension BackgroundViewModel {

    func uploadSampleBackgroundImage(category: String, imageName: String) async -> (url: URL?, filePath: String?) {
        print("uploadBackgroundImage実行")

        guard let backgroundUIImage = UIImage(named: imageName) else {
            return (url: nil, filePath: nil)
        }
        guard let resizedUIImage = resizeUIImage(image: backgroundUIImage) else {
            return (url: nil, filePath: nil)
        }
        guard let imageJpegData = resizedUIImage.jpegData(compressionQuality: 0.8) else {
            return (url: nil, filePath: nil)
        }

        do {
            let storage = Storage.storage()
            let reference = storage.reference()
            let filePath = "/SampleBackgrounds/\(category)/\(imageName)_\(Date()).jpeg"
            let imageRef = reference.child(filePath)
            _ = try await imageRef.putDataAsync(imageJpegData)
            let url = try await imageRef.downloadURL()
            print("背景画像\(imageName)の保存完了")

            return (url: url, filePath: filePath)
        } catch {
            print("背景画像\(imageName)の保存失敗")
            return (url: nil, filePath: nil)
        }
    }

    /// ⚠️このメソッドは開発者のみ使用する。各サンプル背景データをFirestoreにまとめて保存するメソッド⚠️
    /// ユーザー共通で一つのサンプル背景データ群をフェッチして利用する
    func settingAllSampleBackgrounds() {
        print("settingAllBackgrounds実行")
        guard let backgroundRef = db?.collection("backgrounds") else { return }

        BackgroundCategory.allCases.forEach { category in
            print("\(category.categoryName)カテゴリ背景グループの保存開始")

            category.imageContents.forEach { imageName in

                Task {
                    do {
                        print("\(imageName)の保存開始")
                        let uploadImageData = await self.uploadSampleBackgroundImage(category: category.categoryName,
                                                                               imageName: imageName)
                        let backgroundContainer = Background(category: category.categoryName,
                                                             imageName: imageName,
                                                             imageURL: uploadImageData.url,
                                                             imagePath: uploadImageData.filePath)

                        let containerID = "\(category)Backgrounds"
                        /// 各背景画像用のリファレンスを設定
                        let backgroundRowRef = backgroundRef
                            .document(containerID.uppercased())
                            .collection(containerID.lowercased())

                        _ = try backgroundRowRef.addDocument(from: backgroundContainer)

                        print("\(imageName)の保存完了")
                    } catch {
                        print("\(imageName)の保存失敗")
                    }
                }
            }
        }
        print("settingAllBackgrounds終了")
    }
}
