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

    @State private var activeTag: CategoryTag?

    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = true

    var body: some View {

        VStack(spacing: 30) {

            Spacer()

            if showContents {
                VStack(spacing: 15) {
                    Text("背景を選択してください")
                        .tracking(5)
                        .foregroundColor(.white)
                        .opacity(backgroundVM.checkBackgroundAnimation ? 0 : 0.8)

                    Text("チーム: \(teamVM.team?.name ?? "No Name")")
                        .tracking(3)
                        .font(.caption)
                        .foregroundColor(.white)
                        .opacity(backgroundVM.checkBackgroundAnimation ? 0 : 0.6)
                }
                .padding(.bottom, 5)

                CategoriesTagView()
                    .opacity(backgroundVM.checkBackgroundAnimation ? 0 : 1)

                ScrollBackgroundImages()
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                    .opacity(backgroundVM.checkBackgroundAnimation ? 0 : 1)

                VStack(spacing: 40) {
                    Button("保存") {
                        withAnimation(.easeIn(duration: 0.15)) { showProgress = true }

                        Task {
                            do {
                                var updateBackgroundImage: UIImage?
                                // 新しい背景が選択されていた場合、更新処理を実行する
                                if backgroundVM.selectBackgroundCategory == .original {
                                    updateBackgroundImage = backgroundVM.captureBackgroundImage

                                    // サンプル画像選択時、UIImageに変換して格納
                                } else {
                                    let imageName = backgroundVM.selectionBackground?.imageName ?? ""
                                    let selectedBackgroundUIImage = UIImage(named: imageName)
                                    updateBackgroundImage = selectedBackgroundUIImage
                                }

                                if let updateBackgroundImage {
                                    let defaultImagePath = teamVM.team?.backgroundPath
                                    let uploadImageData = await teamVM.uploadTeamImage(updateBackgroundImage)
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
                                        backgroundVM.captureBackgroundImage = nil
//                                        backgroundVM.selectBackgroundCategory = .original
                                        backgroundVM.showSelectBackground = false
                                    }
                                }
                            } catch {
                                withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                                    showContents = false
                                    showProgress = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                        backgroundVM.captureBackgroundImage = nil
                                        backgroundVM.selectBackgroundCategory = .original
                                        backgroundVM.showSelectBackground = false
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
                                    backgroundVM.captureBackgroundImage = nil
//                                    backgroundVM.selectBackgroundCategory = .original
                                    backgroundVM.showSelectBackground = false
                                }
                            }
                        }
                }
                .opacity(backgroundVM.checkBackgroundAnimation ? 0 : 1)
                .overlay {
                    CustomizeToggleButtons()
                        .offset(x: getRect().width / 3)
                }
                .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                .padding(.top, 50)
            } // if showContents

            Spacer().frame(height: 50)
        } // VStack
        .overlay {
            if showProgress {
                SavingProgressView()
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
            }
        }
        .onChange(of: activeTag) { newTag in
            if let newTag {

                Task {
                    await backgroundVM.resetSelectBackgroundImages()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    Task {
                        await backgroundVM.fetchCategoryBackgroundImage(category: newTag.name)
                    }
                }
            }
        }
        .onAppear {
            if let tag = backgroundVM.categoryTag.first {
                activeTag = tag
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
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 30) {
                Spacer().frame(width: 2)

                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray.gradient)
                    .frame(width: 110, height: 220)
                    .opacity(0.7)
                    .overlay {
                        Image(systemName: "photo.artframe")
                            .resizable().scaledToFit()
                            .frame(width: 25)
                            .padding(20)
                            .background(
                                Circle()
                                    .fill(.blue.gradient)
                                    .shadow(radius: 5, x: 2, y: 2)
                            )
                    }

                ForEach(backgroundVM.categoryBackgrounds, id: \.self) { background in

                    SDWebImageView(imageURL: background.imageURL,
                                   width: 110,
                                   height: 220)
                    .shadow(radius: 5, x: 2, y: 2)
                    .shadow(radius: 5, x: 2, y: 2)
                    .shadow(radius: 5, x: 2, y: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    /// タップ範囲調整のため、本体の画像タップ判定はfalseにして
                    /// こちらで処理する
                    .overlay {
                        Rectangle()
                            .frame(width: 110, height: 220)
                            .opacity(0.01)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5)) {
                                    backgroundVM.selectionBackground = background
                                }
                            }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 1)
                            .fill(.gray.gradient)
                    }
//                    .transition(.opacity.combined(with: .offset(x: 0, y: 2)))
                    .scaleEffect(backgroundVM.selectionBackground == background ? 1.15 : 1.0)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "circlebadge.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.green)
                            .frame(width: 20, height: 20)
                            .padding(1)
                            .background(Circle().fill(.white.gradient))
                            .scaleEffect(backgroundVM.selectionBackground == background ? 1.0 : 1.15)
                            .opacity(backgroundVM.selectionBackground == background ? 1.0 : 0.0)
                            .offset(x: 15, y: -25)
                    }
                }
                Spacer().frame(width: 40)
            }
            .frame(height: 280)
            .border(.red)
        } // ScrollView
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
                        Toggle("", isOn: $backgroundVM.checkBackgroundToggle)
                    }
                    VStack {
                        Text("ダークモード").font(.footnote).offset(x: 15)
                        Toggle("", isOn: $applicationDarkMode)
                    }
                }
                .frame(width: 80)
                .padding(.trailing, 30)
                .onChange(of: backgroundVM.checkBackgroundToggle) { newValue in
                    if newValue {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            backgroundVM.checkBackgroundAnimation = true
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, blendDuration: 1)) {
                            backgroundVM.checkBackgroundAnimation = false
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

                    ForEach(backgroundVM.categoryTag) { tag in

                        Text(tag.name)
                                .font(.title3)
                                .foregroundColor(activeTag == tag ? .white : .white.opacity(0.7))
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                                .background {
                                    if activeTag == tag {
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
                                    print("aaa")
                                    withAnimation(.interactiveSpring(response: 0.5,
                                                                     dampingFraction: 0.7,
                                                                     blendDuration: 0.7)) {
                                        activeTag = tag
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
