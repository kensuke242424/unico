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

    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var logVM: LogViewModel

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
                        detectedUser = await userVM.getUserData(id: detectUserID)
                        if let detectedUser {
                            qrReader.isdetectQR.toggle()
                            withAnimation(.spring(response: 0.8, blendDuration: 1)) { joinUserCheckFase = .agree }
                        } else {
                            qrReader.isdetectQR.toggle()
                            teamVM.alertMessage = "ユーザが見つかりませんでした。"
                            teamVM.showErrorAlert.toggle()
                            withAnimation(.spring(response: 0.8, blendDuration: 1)) { joinUserCheckFase = .start }
                        }
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
                            Text(inputUserIDFocused == nil && inputUserIDText.isEmpty ? "ユーザーIDを入力" : "")
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
                            if inputUserIDText.count != 28 { // ユーザーIDは28文字
                                teamVM.showErrorAlert.toggle()
                                teamVM.alertMessage = "IDが正しくありません。入力IDを再度確認してください。"
                                return
                            }
                            if inputUserIDText == userVM.uid ?? "" {
                                teamVM.showErrorAlert.toggle()
                                teamVM.alertMessage = "入力したIDはあなた自身のユーザーIDです。"
                                return
                            }
                            withAnimation{joinUserCheckFase = .check}
                            detectedUser = await userVM.getUserData(id: inputUserIDText)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if detectedUser != nil {
                                    withAnimation{ joinUserCheckFase = .agree }
                                } else {
                                    teamVM.alertMessage = "入力したidのユーザーは見つかりませんでした。"
                                    teamVM.showErrorAlert.toggle()
                                    withAnimation{ joinUserCheckFase = .start }
                                    return
                                }
                            }
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
                                    guard let detectedUser, let team = teamVM.team else { return }

                                    // すでに加入済みでないかチェック
                                    if teamVM.isUserAlreadyMember(userId: detectedUser.id) {
                                        hapticErrorNotification()
                                        teamVM.alertMessage = "こちらのユーザーは既にチームに所属しています。"
                                        teamVM.showErrorAlert.toggle()

                                    } else {
                                        _ = await teamVM.setDetectedNewMember(from: detectedUser)
                                        _ = try await teamVM.passJoinTeamToDetectedMember(for: detectedUser,
                                                                                         from: userVM.currentJoinTeam)
                                        withAnimation(.spring(response: 0.8, blendDuration: 1)) { isAgreed.toggle() }
                                        hapticSuccessNotification()

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            withAnimation(.spring(response: 0.5, blendDuration: 1)) {
                                                teamVM.isShowSearchedNewMemberJoinTeam.toggle()
                                                logVM.addLog(to: team,
                                                             by: userVM.user,
                                                             type: .join(detectedUser, team))
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                            inputUserIDText = ""
                                            isAgreed.toggle()
                                            joinUserCheckFase = .start
                                        }
                                    }
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
