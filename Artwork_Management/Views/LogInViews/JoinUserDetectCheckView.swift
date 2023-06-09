//
//  JoinUserCheckView.swift
//  Artwork_Management
//
//  Created by 中川賢亮 on 2023/01/17.
//

import SwiftUI

struct JoinUserDetectCheckView: View {

    enum JoinUserCheckFase {
        case start, check, agree
    }

    enum InputUserIDFocused {
        case check
    }

    @StateObject var qrReader: QRReader = QRReader()
    @StateObject var teamVM: TeamViewModel

    @State private var joinUserCheckFase: JoinUserCheckFase = .start
    @State private var inputUserIDText: String = ""
    @State private var isShowQRReader: Bool = false
    @State private var isAgreed: Bool = false
    @State private var showContent: Bool = false
    @State private var detectedUser: User?

    @FocusState var inputUserIDFocused: InputUserIDFocused?
    /// キーボード出現時、Viewを上にずらす
    @State private var showKeyboardOffset: Bool = false

    var body: some View {

        ZStack {
            Color(.black)
                .opacity(0.8)
                .background(.ultraThinMaterial)
                .opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    inputUserIDFocused = nil
                }

            VStack(spacing: 30) {

                LogoMark()
                    .frame(height: 30)
                    .scaleEffect(0.45)
                    .opacity(0.4)
                    .padding(.bottom, 30)

                // Infomation Text...
                VStack(spacing: 30) {
                    Text("メンバーを招待する")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .opacity(0.7)
                        .tracking(10)

                    if showContent {
                        Group {
                            switch joinUserCheckFase {

                            case .start:
                                VStack(spacing: 10) {
                                    Text("以下の方法でチームに招待します。")
                                        .padding(.bottom, 8)
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("方法1: カメラでQRコードを読み込む。")
                                        Text("方法2: 相手のユーザIDを入力する。")
                                    }
                                    .fontWeight(.bold)
                                }

                            case .check:
                                VStack(spacing: 10) {
                                    Text("ユーザーを探しています...")
                                }

                            case .agree:
                                if !isAgreed {
                                    VStack(spacing: 10) {
                                        Text("ユーザーが見つかりました。")
                                            .padding(.bottom, 8)
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("こちらのユーザーをチームに招待しますか？")
                                        }
                                        .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                        .font(.caption)
                        .tracking(3)
                        .opacity(0.6)
                        .foregroundColor(.white)
                    }
                } // if showContent

                // search fase view...
                if showContent {
                    Group {
                        switch joinUserCheckFase {
                        case .start:
                            startFaseView()
                        case .check:
                            ProgressView()
                        case .agree:
                            agreeFaseView()
                        }
                    }
                    .frame(height: 250)
                    .padding(.top, 30)

                    Button {
                        qrReader.stopSession()
                        withAnimation { showContent.toggle() }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                teamVM.isShowSearchedNewMemberJoinTeam.toggle()
                            }
                        }
                    } label: {
                        Label("キャンセル", systemImage: "multiply.circle.fill")
                            .foregroundColor(.white)
                            .opacity(0.7)
                    }
                    .alert("エラー", isPresented: $teamVM.showErrorAlert) {
                        Button("OK") {
                            teamVM.alertMessage = ""
                            teamVM.showErrorAlert.toggle()
                        }
                    } message: {
                        Text(teamVM.alertMessage)
                    } // alert
                    .opacity(isAgreed ? 0.0 : 1.0)
                    .padding(.top)
                } // if showContent
            }
            .offset(y: showKeyboardOffset ? -100 : 0)
        }
        // QRコードを読み取るためのカメラView
        .sheet(isPresented: $isShowQRReader) {
            ZStack {
                QRReaderView(caLayer: qrReader.videoPreviewLayer)
                    .ignoresSafeArea()
                Text("QRコードを画面内に入れてください")
                    .offset(y: -getRect().height / 3 + 20)
            }

        }
        // QRコードが読み取れたらカメラを閉じる
        .onChange(of: qrReader.isdetectQR) { detect in

            Task {
                if detect {
                    hapticSuccessNotification()
                    isShowQRReader.toggle()
                    withAnimation(.spring(response: 0.8, blendDuration: 1)) { joinUserCheckFase = .check }

                    do {
                        let detectUserID = qrReader.captureQRData
                        inputUserIDText = detectUserID
                        detectedUser = try await teamVM.detectUserFetchData(id: detectUserID)
                        print("detectedUser: \(detectedUser)")
                        qrReader.isdetectQR.toggle()
                        withAnimation(.spring(response: 0.8, blendDuration: 1)) { joinUserCheckFase = .agree }
                    } catch {
                        qrReader.isdetectQR.toggle()
                        teamVM.alertMessage = "ユーザが見つかりませんでした。"
                        teamVM.showErrorAlert.toggle()
                        withAnimation(.spring(response: 0.8, blendDuration: 1)) { joinUserCheckFase = .start }
                    }
                }
            }
        }
        // キーボードの表示状態を監視
        .onChange(of: inputUserIDFocused) { newValue in
            if newValue == .check {
                withAnimation { showKeyboardOffset = true }
            } else {
                withAnimation { showKeyboardOffset = false }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showContent.toggle()
                }
            }
        }
    } // body

    func startFaseView() -> some View {

        VStack {
            // Input QRCode view...
            VStack {
                Text("QRコードを読む")
                    .foregroundColor(.white)
                    .font(.subheadline).tracking(3).opacity(0.6)

                Button {
                    // QR読み込みカメラの起動
                    qrReader.startSession()
                    isShowQRReader.toggle()
                } label: {
                    Image(systemName: "camera.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)

            // Input userID view...
            VStack(spacing: 40) {
                TextField("", text: $inputUserIDText)
                    .frame(width: 300)
                    .foregroundColor(.white)
                    .focused($inputUserIDFocused, equals: .check)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.center)
                    .background {
                        ZStack {
                            Text(inputUserIDFocused == nil && inputUserIDText.isEmpty ? "ユーザーIDを貼り付け" : "")
                                .foregroundColor(.white.opacity(0.3))
                            Rectangle().foregroundColor(.white.opacity(0.3)).frame(height: 1)
                                .offset(y: 20)
                        }
                    }
                Button("ID検索") {
                    // ユーザIDを使ってFirestore内からユーザを検索
                    Task {
                        do {
                            if inputUserIDText.isEmpty {
                                teamVM.showErrorAlert.toggle()
                                teamVM.alertMessage = "ユーザーIDを入力してください"
                                return
                            }

                            joinUserCheckFase = .check
                            detectedUser = try await teamVM.detectUserFetchData(id: inputUserIDText)
                            if detectedUser != nil {
                                joinUserCheckFase = .agree
                            } else {
                                joinUserCheckFase = .start
                            }

                        } catch {
                            print("uid検索の結果、Firestoreにユーザーが存在しませんでした")
                            teamVM.alertMessage = "入力したidのユーザーは見つかりませんでした。"
                            teamVM.showErrorAlert.toggle()
                            joinUserCheckFase = .start
                            return
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    func agreeFaseView() -> some View {

        VStack(spacing: 30) {

            AsyncImageCircleIcon(photoURL: detectedUser?.iconURL, size: 150)

            Text(detectedUser?.name ?? "???")
                .foregroundColor(.white)
                .tracking(5)

            if !isAgreed {
                HStack(spacing: 20) {
                    Group {
                        Button("やり直す") {
                            inputUserIDText = ""
                            withAnimation(.spring(response: 0.3, blendDuration: 1)) { joinUserCheckFase = .start }
                        }
                        .buttonStyle(.bordered)

                        Button("招待する") {
                            Task {
                                do {
                                    _ = try await teamVM.addNewTeamMember(data: detectedUser!)
                                    _ = try await teamVM.addTeamIDToJoinedUser(to: detectedUser!.id)
                                    withAnimation(.spring(response: 0.8, blendDuration: 1)) { isAgreed.toggle() }
                                    hapticSuccessNotification()

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                            teamVM.isShowSearchedNewMemberJoinTeam.toggle()
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                        inputUserIDText = ""
                                        isAgreed.toggle()
                                        joinUserCheckFase = .start
                                    }
                                } catch CustomError.memberDuplication {
                                    hapticErrorNotification()
                                    teamVM.alertMessage = "こちらのユーザーは既にチームに所属しています。"
                                    teamVM.showErrorAlert.toggle()
                                } catch {
                                    hapticErrorNotification()
                                    teamVM.alertMessage = "ユーザーの紹介に失敗しました。もう一度試してみてください。"
                                    teamVM.showErrorAlert.toggle()
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(width: 100, height: 50)
                }
            } else {
                Text("チームに加入しました！")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .tracking(5)
            }
        }
    }
} // View

struct JoinUserCheckView_Previews: PreviewProvider {
    static var previews: some View {

        JoinUserDetectCheckView(teamVM: TeamViewModel())
            .background {
                Image("background_1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
    }
}
