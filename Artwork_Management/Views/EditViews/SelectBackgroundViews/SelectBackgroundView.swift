//
//  SelectBackgroundView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/06/10.
//

import SwiftUI

struct SelectBackgroundView: View {

    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var backgroundVM: BackgroundViewModel

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
                                    let resizedImage = teamVM.resizeUIImage(image: updateBackgroundImage,
                                                                            width: getRect().width * 4)
                                    let uploadImageData = await teamVM.uploadTeamImage(resizedImage)
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
                                        backgroundVM.selectBackgroundCategory = .original
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
                                    backgroundVM.selectBackgroundCategory = .original
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
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 30) {
                ForEach(backgroundVM.selectBackgroundCategory.imageContents, id: \.self) { value in
                    Group {
//                        if value == .original {
//                            Group {
//                                if let captureNewImage = inputTab.captureBackgroundImage {
//                                    Image(uiImage: captureNewImage)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 120, height: 250)
//                                } else {
//                                    SDWebImageView(imageURL: teamVM.team?.backgroundURL,
//                                                   width: 120,
//                                                   height: 250)
//                                }
//                            }
//                            .overlay {
//                                Button("写真を挿入") {
//                                    inputTab.showPickerView.toggle()
//                                }
//                                .font(.footnote)
//                                .buttonStyle(.borderedProminent)
//                            }
//                        } else {
                        Image(uiImage: value)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 250)
//                        }
                    } // Group
                    .clipped()
                    .scaleEffect(backgroundVM.selectedBackgroundImage == value ? 1.15 : 1.0)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                            .scaleEffect(backgroundVM.selectedBackgroundImage == value ? 1.0 : 1.15)
                            .opacity(backgroundVM.selectedBackgroundImage == value ? 1.0 : 0.0)
                            .offset(x: 15, y: -20)
                    }
                    //TODO: 両サイドの間隔開ける
//                    .padding(.leading, value == .original ? 40 : 0)
//                    .padding(.trailing, value == .sample4 ? 40 : 0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5)) {
                            backgroundVM.selectedBackgroundImage = value
                        }
                    }
                }
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
} // SelectBackgroundView

struct SelectBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SelectBackgroundView()
            .environmentObject(BackgroundViewModel())
    }
}
