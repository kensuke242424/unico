//
//  SelectBackgroundView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/10.
//

import SwiftUI

/// チームルームの背景を変更編集するために用いる背景セレクトビュー。アプリサイドメニュー内のシステム項目から呼び出される。
/// チーム背景データはユーザーごとに独立しており、他のメンバーと干渉しない。
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

                if backgroundVM.savingWait {
                    HStack(spacing: 10) {
                        Text("オリジナル背景を保存中です...")
                            .font(.footnote)
                            .tracking(5)
                            .foregroundColor(.white.opacity(0.8))
                        ProgressView()
                    }
                }

                SelectionBackgroundCards(showPicker: $showPicker)
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                    .opacity(backgroundVM.checkMode ? 0 : 1)

                VStack(spacing: 40) {
                    Button("保存") {
                        Task {
                            do {
                                if let selectedBackground = backgroundVM.selectBackground {
                                    _ = try await userVM.updateJoinTeamBackground(data: selectedBackground)
                                }
                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                    showContents = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                        backgroundVM.croppedUIImage = nil
                                        backgroundVM.selectBackground = nil
                                        backgroundVM.showEdit = false
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
                                    backgroundVM.croppedUIImage = nil
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

            Spacer()
        } // VStack

        .cropImagePicker(option: .rectangle,
                         show: $showPicker,
                         croppedImage: $backgroundVM.croppedUIImage)
        .overlay {
            if showProgress {
                SavingProgressView()
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
            }
        }
        .onChange(of: backgroundVM.croppedUIImage) { newImage in
            guard let newImage else { return }
            Task{
                withAnimation { backgroundVM.savingWait = true }
                let resizedImage = backgroundVM.resizeUIImage(image: newImage)
                let uploadImage = await userVM.uploadMyNewBackground(resizedImage)
                await userVM.setMyNewBackground(url: uploadImage.url, path: uploadImage.filePath)
                withAnimation { backgroundVM.savingWait = false }
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
