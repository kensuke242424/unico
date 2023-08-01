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

    let backgroundWidth : CGFloat = UIScreen.main.bounds.width
    /// サインアップ時に背景選択が無かった場合に、初期背景として使用する
    let sampleBackground = Background(category: "music",
                                      imageName: "music_1",
                                      imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/unico-cc222.appspot.com/o/SampleBackgrounds%2Fmusic%2Fmusic_1_2023-07-30%2012%3A31%3A33%20%2B0000.jpeg?alt=media&token=a7c7ea84-2a68-4459-acf9-06fa583b6639"),
                                      imagePath: "gs://unico-cc222.appspot.com/SampleBackgrounds/music/music_1_2023-07-30 12:31:33 +0000.jpeg")


    let categoryTag: [CategoryTag] =
    [
        .init(name: "music"),
        .init(name: "cafe"),
        .init(name: "cute"),
        .init(name: "cool"),
        .init(name: "dark"),
        .init(name: "art"),
        .init(name: "technology"),
        .init(name: "beautiful"),
    ]

    func resetSelectBackgroundImages() async {
        withAnimation(.easeInOut(duration: 0.5)) {
            DispatchQueue.main.async {
                withAnimation {
//                    self.categoryBackgrounds.removeFirst(self.categoryBackgrounds.count)
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
//            for document in documents {
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
//                    self.createTimeSortBackgrounds(order: .up)
                }
            }
        } catch {
            print("背景データの取得失敗")
        }
    }

    // TODO: 6.15 まだ実装できてない
//    func createTimeSortBackgrounds(order: UpDownOrder) {
//
//        switch order {
//        case .up:
//            categoryBackgrounds.sort { before, after in
//                before.createTime!.dateValue() > after.createTime!.dateValue() ? true : false
//            }
//
//        case .down:
//            categoryBackgrounds.sort { before, after in
//                before.createTime!.dateValue() < after.createTime!.dateValue() ? true : false
//            }
//        }
//    }
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

    func resizeUIImage(image: UIImage?) -> UIImage? {

        let width = backgroundWidth

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

    /// ⚠️このメソッドは開発者のみ使用する。各サンプル背景データをFirestoreにまとめて保存するメソッド⚠️
    /// ユーザー共通で一つのサンプル背景データ群をフェッチして利用する
    func settingAllBackgrounds() {
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

/// アプリ内のデフォルトで用意されている背景画像サンプルの静的データを管理するenum
enum BackgroundCategory: CaseIterable {
    case original, music, art, cafe, beautiful, cool, cute, dark, technology

    var categoryName: String {
        switch self {
        case .original:
            return "original"
        case .music:
            return "music"

        case .art:
            return "art"

        case .cafe:
            return "cafe"

        case .beautiful:
            return "beautiful"

        case .cool:
            return "cool"

        case .cute:
            return "cute"

        case .dark:
            return "dark"

        case .technology:
            return "technology"
        }
    }

    var imageContents: [String] {
        switch self {
        case .original:
            return []
        case .music:
            return SampleBackgroundsImageName.music
        case .art:
            return SampleBackgroundsImageName.art
        case .cafe:
            return SampleBackgroundsImageName.cafe
        case .beautiful:
            return SampleBackgroundsImageName.beautiful
        case .cool:
            return SampleBackgroundsImageName.cool
        case .cute:
            return SampleBackgroundsImageName.cute
        case .dark:
            return SampleBackgroundsImageName.dark
        case .technology:
            return SampleBackgroundsImageName.technology
        }
    }
}

struct SampleBackgroundsImageName {

    static let cool: [String] =
    [
        "cool_1",
        "cool_2",
        "cool_3",
        "cool_4",
        "cool_5",
        "cool_6",
        "cool_7",
        "cool_8",
        "cool_9",
        "cool_10",
        "cool_11",
        "cool_12",
    ]

    static let art: [String] =
    [
        "art_1",
        "art_2",
        "art_3",
        "art_4",
        "art_5",
        "art_6",
        "art_7",
        "art_8",
        "art_9",
        "art_10",
        "art_11",
    ]

    static let cafe: [String] =
    [
        "cafe_1",
        "cafe_2",
        "cafe_3",
        "cafe_4",
        "cafe_5",
        "cafe_6",
        "cafe_7",
        "cafe_8",
        "cafe_9",
        "cafe_10",
    ]

    static let cute: [String] =
    [
        "cute_1",
        "cute_2",
        "cute_3",
        "cute_4",
        "cute_5",
        "cute_6",
        "cute_7",
        "cute_8",
        "cute_9",
        "cute_10",
        "cute_11",
        "cute_12",
        "cute_13",
    ]

    static let dark: [String] =
    [
        "dark_1",
        "dark_2",
        "dark_3",
        "dark_4",
        "dark_5",
        "dark_6",
        "dark_7",
        "dark_8",
        "dark_9",
        "dark_10",
        "dark_11",
    ]

    static let music: [String] =
    [
        "music_1",
        "music_2",
        "music_3",
        "music_4",
        "music_5",
        "music_6",
        "music_7",
        "music_8",
        "music_9",
        "music_10",
        "music_11",
        "music_12",
        "music_13",
        "music_14",
    ]

    static let beautiful: [String] =
    [
        "beautiful_1",
        "beautiful_2",
        "beautiful_3",
        "beautiful_4",
        "beautiful_5",
        "beautiful_6",
        "beautiful_7",
        "beautiful_8",
        "beautiful_9",
        "beautiful_10",
        "beautiful_11",
    ]

    static let technology: [String] =
    [
        "technology_1",
        "technology_3",
        "technology_4",
        "technology_5",
        "technology_6",
        "technology_7",
        "technology_8",
        "technology_9",
        "technology_10",
        "technology_11",
        "technology_12",
        "technology_13",
    ]
}
