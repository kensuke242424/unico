//
//  SelectBackgroundView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/10.
//

import SwiftUI

struct EditTeamBackgroundView: View {

    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

    @State private var showContents: Bool = false
    @State private var showProgress: Bool = false
    @State private var showPicker: Bool = false

    var body: some View {

        VStack(spacing: 30) {

            Spacer()

            if showContents {
                VStack(spacing: 15) {
                    Text("背景を選択してください")
                        .tracking(5)
                        .foregroundColor(.white)
                        .opacity(backgroundVM.checkMode ? 0 : 0.8)

                    Text("チーム: \(teamVM.team?.name ?? "No Name")")
                        .tracking(3)
                        .font(.caption)
                        .foregroundColor(.white)
                        .opacity(backgroundVM.checkMode ? 0 : 0.6)
                }
                .padding(.bottom, 5)

                BackgroundCategoriesTagView()
                    .opacity(backgroundVM.checkMode ? 0 : 1)

                SelectionBackgroundCards(showPicker: $showPicker)
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                    .opacity(backgroundVM.checkMode ? 0 : 1)

                VStack(spacing: 40) {
                    Button("保存") {
                        withAnimation(.easeIn(duration: 0.15)) { showProgress = true }

                        Task {
                            do {
                                var updateImage: UIImage?
//                                // 新しい背景が選択されていた場合、更新処理を実行する
//                                if backgroundVM.selectCategory == .original {
//                                    updateImage = backgroundVM.captureUIImage
//
//                                    // サンプル画像選択時、UIImageに変換して格納
//                                } else {
                                    let imageName = backgroundVM.selectBackground?.imageName ?? ""
                                    let selectedUIImage = UIImage(named: imageName)
                                    updateImage = selectedUIImage
//                                }

                                if let updateImage {
                                    let defaultImagePath = teamVM.team?.backgroundPath
                                    let resizedUIImage = backgroundVM.resizeUIImage(image: updateImage)
                                    let uploadImageData = await teamVM.uploadTeamImage(updateImage)
                                    let _ = try await teamVM.updateTeamBackgroundImage(data: uploadImageData)
                                    // 新規背景画像の保存が完了したら、以前の背景データを削除
                                    let _ = await teamVM.deleteTeamImageData(path: defaultImagePath)
                                }
                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                    showContents = false
                                    showProgress = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                        backgroundVM.captureUIImage = nil
                                        backgroundVM.selectBackground = nil
                                        backgroundVM.showEdit = false
                                    }
                                }

                            } catch {
                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                    showContents = false
                                    showProgress = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                        backgroundVM.captureUIImage = nil
                                        backgroundVM.selectBackground = nil
                                        backgroundVM.showEdit = false
                                        Task {
                                            await backgroundVM.resetSelectBackgroundImages()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Label("キャンセル", systemImage: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                showContents.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                    backgroundVM.captureUIImage = nil
                                    backgroundVM.selectBackground = nil
                                    backgroundVM.showEdit = false
                                }
                                Task {
                                    await backgroundVM.resetSelectBackgroundImages()
                                }
                            }
                        }
                }
                .opacity(backgroundVM.checkMode ? 0 : 1)
                .overlay {
                    EditBackgroundControlButtons()
                        .offset(x: getRect().width / 3)
                }
                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                .padding(.top, 50)
            } // if showContents

            Spacer().frame(height: 50)
        } // VStack
        .sheet(isPresented: $showPicker) {
            PHPickerView(captureImage: $backgroundVM.captureUIImage, isShowSheet: $showPicker)
        }
        .overlay {
            if showProgress {
                SavingProgressView()
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
            }
        }
        .onChange(of: backgroundVM.captureUIImage) { newImage in
            guard let newImage else { return }
            Task{
                let resizedImage = backgroundVM.resizeUIImage(image: newImage)
                let uploadImage = await userVM.uploadCurrentTeamMyBackground(resizedImage)
                await userVM.addCurrentTeamMyBackground(url: uploadImage.url, path: uploadImage.filePath)
            }
        }
        .onChange(of: backgroundVM.selectCategory) { newCategory in
            /// タグ「original」を選択時、joinsに保存している現在のチームの画像データ群を取り出して
            /// backgroundVMの背景管理プロパティに橋渡しする
            if newCategory == .original {
                Task {
                    await backgroundVM.resetSelectBackgroundImages()
                    let myBackgrounds = userVM.getCurrentTeamMyBackgrounds()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        backgroundVM.appendMyBackgrounds(images: myBackgrounds)
                    }
                }
            } else {
                Task {
                    await backgroundVM.resetSelectBackgroundImages()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    Task {
                        await backgroundVM.fetchCategoryBackgroundImage(category: newCategory.categoryName)
                    }
                }
            }
        }
        .onAppear {
            Task {
                let startCategory = backgroundVM.selectCategory.categoryName
                await backgroundVM.fetchCategoryBackgroundImage(category: startCategory)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 1, blendDuration: 1)) {
                    showContents.toggle()
                }
            }
        }
    }
}
