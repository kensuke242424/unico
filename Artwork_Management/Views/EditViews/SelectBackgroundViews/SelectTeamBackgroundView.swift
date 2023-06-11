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
    @Namespace private var animation

    @State private var showContents: Bool = false
    @State private var showProgress: Bool = false

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

                ScrollBackgroundImages()
                    .transition(.opacity.combined(with: .offset(x: 0, y: 40)))
                    .opacity(backgroundVM.checkBackgroundAnimation ? 0 : 1)

                VStack(spacing: 40) {
                    Button("保存") {
                        withAnimation(.easeIn(duration: 0.15)) { showProgress = true }
                        // 新しい背景が選択されていた場合、更新処理を実行する
                        Task {
                            do {
                                var updateBackgroundImage: UIImage?
                                if backgroundVM.selectBackgroundCategory == .original {
                                    updateBackgroundImage = backgroundVM.captureBackgroundImage
                                } else {
                                    updateBackgroundImage = backgroundVM.selectedBackgroundImage
                                }
                                if let updateBackgroundImage {
                                    let defaultImagePath = teamVM.team?.backgroundPath
//                                    let resizedImage = teamVM.resizeUIImage(image: updateBackgroundImage,
//                                                                            width: getRect().width * 4)
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
        .onAppear {
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
                Spacer().frame(width: 40)
                ForEach(backgroundVM.selectBackgroundCategory.imageContents, id: \.self) { imageString in

                    let backgroundUIImageRow = UIImage(named: imageString)

                    Group {
                        Image(imageString)
                                .resizable()
                                .scaledToFill()
                                .allowsHitTesting(false)
                                .frame(width: 110, height: 220)
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
                                                backgroundVM.selectedBackgroundImage = backgroundUIImageRow
                                            }
                                        }
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(lineWidth: 1)
                                        .fill(.gray.gradient)
                                }

                    } // Group

                    .scaleEffect(backgroundVM.selectedBackgroundImage == backgroundUIImageRow ? 1.15 : 1.0)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                            .scaleEffect(backgroundVM.selectedBackgroundImage == backgroundUIImageRow ? 1.0 : 1.15)
                            .opacity(backgroundVM.selectedBackgroundImage == backgroundUIImageRow ? 1.0 : 0.0)
                            .offset(x: 15, y: -20)
                    }
                }
                Spacer().frame(width: 40)
            }
            .frame(height: 300)
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

    @ViewBuilder
    func BackgroundCategoriesTagView() -> some View {
        HStack {

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // MEMO: 未グループタグのアイテムがあるかどうかで「未グループ」タグの表示を切り替える
                    ForEach(TeamBackgroundContents.allCases, id: \.self) { category in

                        Text(category.categoryName)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background {
                                if backgroundVM.selectBackgroundCategory == category {
                                    Capsule()
                                        .foregroundColor(userVM.memberColor.color3)
                                        .matchedGeometryEffect(id: "ACTIVETAG", in: animation)
                                } else {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.6))
                                }
                            }
                            .foregroundColor(backgroundVM.selectBackgroundCategory == category ? .white : .white.opacity(0.7))
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                                    backgroundVM.selectBackgroundCategory = category
                                }
                            }
                    } // ForEath
                } // HStack
                .padding(.leading, 15)
            } // ScrollView
            /// スクロール時の引っ掛かりを無くす
            .introspectScrollView { scrollView in
                 scrollView.isDirectionalLockEnabled = true
                 scrollView.bounces = false
            }
        }
        .padding(.top)
    }
} // SelectBackgroundView

fileprivate struct BackgroundCategoriesTagView: View {

    @EnvironmentObject var userVM: UserViewModel
    let tags: [Tag]

    @State private var activeTag: Tag?
    @Namespace private var animation

    var body: some View {

        HStack {

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // MEMO: 未グループタグのアイテムがあるかどうかで「未グループ」タグの表示を切り替える
                    ForEach(tags) { tag in

                        Text(tag.tagName)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background {
                                if activeTag == tag {
                                    Capsule()
                                        .foregroundColor(userVM.memberColor.color3)
                                        .matchedGeometryEffect(id: "ACTIVETAG", in: animation)
                                } else {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.6))
                                }
                            }
                            .foregroundColor(activeTag == tag ? .white : .white.opacity(0.7))
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                                    activeTag = tag
                                }
                            }
                    } // ForEath
                } // HStack
                .padding(.leading, 15)
            } // ScrollView
            /// スクロール時の引っ掛かりを無くす
            .introspectScrollView { scrollView in
                 scrollView.isDirectionalLockEnabled = true
                 scrollView.bounces = false
            }
        }
        .padding(.top)
    }

}

struct SelectBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SelectTeamBackgroundView()
            .environmentObject(TeamViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(BackgroundViewModel())
    }
}
