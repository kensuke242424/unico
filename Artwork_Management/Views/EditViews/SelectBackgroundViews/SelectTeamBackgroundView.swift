//
//  SelectBackgroundView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/10.
//

import SwiftUI

struct SelectTeamBackgroundView: View {

    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel
    @Namespace private var tagAnimation

    @State private var showContents: Bool = false
    @State private var showProgress: Bool = false
    @State private var showPicker: Bool = false

    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = true

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

                CategoriesTagView()
                    .opacity(backgroundVM.checkMode ? 0 : 1)

                ScrollBackgroundImages()
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
                    CustomizeToggleButtons()
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
    } // body

    @ViewBuilder
    func ScrollBackgroundImages() -> some View {
        let contentWidth: CGFloat = 140
        let categoryContents: CGFloat = CGFloat(backgroundVM.selectCategory.imageContents.count)
        let myBackgroundContents: CGFloat = CGFloat(userVM.user?.joins[userVM.currentTeamIndex].myBackgrounds.count ?? 0)
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 30) {
                Spacer().frame(width: 10)

                let currentIndex = userVM.currentTeamIndex

                if backgroundVM.selectCategory == .original {

                    ForEach(userVM.user?.joins[currentIndex].myBackgrounds ?? [], id: \.self) { background in
                        BackgroundCardView(background)
                            /// オリジナル背景画像のみ、削除が可能
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    // オリジナル背景削除
                                    backgroundVM.deleteTarget = background
                                    backgroundVM.showDeleteAlert.toggle()
                                }
                            }
                            .alert("確認", isPresented: $backgroundVM.showDeleteAlert) {
                                Button("削除", role: .destructive) {
                                    // 一瞬ずらさないとアラートが瞬間だけ再表示されてしまう🧐
                                    guard let deleteTargetImage = backgroundVM.deleteTarget else { return }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        backgroundVM.deleteBackground(path: background.imagePath)
                                        userVM.deleteCurrentTeamMyBackground(deleteTargetImage)
                                    }
                                }
                                .foregroundColor(.red)
                            } message: {
                                Text("背景を削除しますか？")
                            } // alert
                    }
                    ShowPickerCardView()
                } else {
                    ForEach(backgroundVM.categoryBackgrounds, id: \.self) { background in
                        BackgroundCardView(background)
                    }
                }
                Spacer().frame(width: 40)
            } // LazyHStack
            .frame(height: 280)
        } // ScrollView
    }

    @ViewBuilder
    func BackgroundCardView(_ background: Background) -> some View {
        SDWebImageView(imageURL: background.imageURL,
                       width: 110,
                       height: 220)
//        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 40)))
        .shadow(radius: 5, x: 2, y: 2)
        .shadow(radius: 5, x: 2, y: 2)
        .shadow(radius: 5, x: 2, y: 2)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        /// タップ範囲調整のため、本体の画像タップ判定はfalseにしてこちらで処理する
        .overlay {
            Rectangle()
                .frame(width: 110, height: 220)
                .opacity(0.01)
                .onTapGesture {
                    withAnimation(.spring(response: 0.5)) {
                        backgroundVM.selectBackground = background
                    }
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 1)
                .fill(.gray.gradient)
        }
        .scaleEffect(backgroundVM.selectBackground == background ? 1.15 : 1.0)
        .overlay(alignment: .topTrailing) {
            Image(systemName: "circlebadge.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.green)
                .frame(width: 20, height: 20)
                .padding(1)
                .background(Circle().fill(.white.gradient))
                .scaleEffect(backgroundVM.selectBackground == background ? 1.0 : 1.15)
                .opacity(backgroundVM.selectBackground == background ? 1.0 : 0.0)
                .offset(x: 15, y: -25)
        }
    }

    @ViewBuilder
    func ShowPickerCardView() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.gray.gradient)
            .frame(width: 110, height: 220)
            .opacity(0.7)
            .overlay {
                Button {
                    // 写真キャプチャ
                    showPicker.toggle()
                } label: {
                    Image(systemName: "photo.artframe")
                        .resizable().scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 22)
                        .padding(18)
                        .background(
                            Circle()
                                .fill(.blue.gradient)
                                .shadow(radius: 5, x: 2, y: 2)
                        )
                }
            }
    }

    @ViewBuilder
    func CustomizeToggleButtons() -> some View {
        HStack {
            Spacer()
            ZStack {
                BlurView(style: .systemThickMaterial)
                    .frame(width: 90, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .opacity(0.8)

                VStack(spacing: 20) {
                    VStack {
                        Text("背景を確認").font(.footnote).offset(x: 15)
                        Toggle("", isOn: $backgroundVM.checkModeToggle)
                    }
                    VStack {
                        Text("ダークモード").font(.footnote).offset(x: 15)
                        Toggle("", isOn: $applicationDarkMode)
                    }
                }
                .frame(width: 80)
                .padding(.trailing, 30)
                .onChange(of: backgroundVM.checkModeToggle) { newValue in
                    if newValue {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            backgroundVM.checkMode = true
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            backgroundVM.checkMode = false
                        }
                    }
                }
            }
        }
    }

    /// 背景画像のカテゴリ選択を管理するタグビュー
    @ViewBuilder
    func CategoriesTagView() -> some View {
        HStack {

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {

                    ForEach(BackgroundCategory.allCases, id: \.self) { category in

                        Text(category.categoryName)
                            .tracking(3)
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundColor(backgroundVM.selectCategory == category ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background {
                                if backgroundVM.selectCategory == category {
                                    Capsule()
                                        .foregroundColor(userVM.memberColor.color3)
                                        .matchedGeometryEffect(id: "ACTIVETA", in: tagAnimation)
                                } else {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.6))
                                }
                            }
                            .contentShape(Capsule())
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.5,
                                                                 dampingFraction: 0.7,
                                                                 blendDuration: 0.7)) {
                                    backgroundVM.selectCategory = category
                                }
                            }
                    } // ForEath
                } // HStack
                .padding(.horizontal, 15)
            } // ScrollView
        }
        .padding(.top)
    }
} // SelectBackgroundView

struct SelectBackgroundView_Previews: PreviewProvider {
    static var previews: some View {

        SelectTeamBackgroundView()
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(BackgroundViewModel())
            .background {
                Image("music_1")
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        Color.black.opacity(0.7)
                    }
                    .ignoresSafeArea()
            }
    }
}
