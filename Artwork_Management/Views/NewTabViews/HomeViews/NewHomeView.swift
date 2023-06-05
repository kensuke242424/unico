//
//  HomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct NewHomeView: View {

    private struct NowTimeParts {
        var transitionOffset: CGSize = .zero
        var initialOffset: CGSize = .zero
        var transitionScale: CGFloat = 1.0
        var initialScale: CGFloat = 1.0
        var desplayState: Bool = true
        var backState: Bool = false
        var pressingAnimation: Bool = false
    }

    private struct TeamNewsParts {
        var transitionOffset: CGSize = .zero
        var initialOffset: CGSize = .zero
        var transitionScale: CGFloat = 1.0
        var initialScale: CGFloat = 1.0
        var desplayState: Bool = true
        var backState: Bool = false
        var pressingAnimation: Bool = false
    }

    @EnvironmentObject var teamVM: TeamViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @StateObject var itemVM: ItemViewModel

    /// Tab親Viewから受け取った状態変数群
    @Binding var inputTab: InputTab
    
    @State private var inputTime = InputTimesView()

    /// View Property
    @State private var animationContent: Bool = true
    @State private var nowTime = NowTimeParts()
    @State private var teamNews = TeamNewsParts()

    @State private var isActiveEditHome : Bool = false

    @AppStorage("applicationDarkMode") var applicationDarkMode: Bool = false
    
    var body: some View {

        GeometryReader {
            let size = $0.size
            let rect = $0.frame(in: .global)
            
            VStack {

                if animationContent {
                    NowTimeView(size)
                        .foregroundColor(applicationDarkMode ? .white : .black)
                        .opacity(1 - min((-inputTab.scrollProgress * 2), 1))
                        .blur(radius: inputTab.checkBackgroundAnimation ||
                                      !inputTab.showSelectBackground ? 0 : 2)
                        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 20)))
                        .scaleEffect(nowTime.transitionScale)
                        .scaleEffect(nowTime.pressingAnimation ? 1.02 : 1)
                        .offset(nowTime.transitionOffset)
                        .customDragGesture(
                            active: $homeVM.isActiveEdit,
                            transition: $nowTime.transitionOffset,
                            initial: $nowTime.initialOffset
                        )
                        .customMagnificationGesture(
                            active: $homeVM.isActiveEdit,
                            transition: $nowTime.transitionScale,
                            initial: $nowTime.initialScale
                        )
                        .customLongPressGesture(
                            pressing: $nowTime.pressingAnimation,
                            backState: $inputTab.pressingAnimation,
                            perform: $homeVM.isActiveEdit
                        )
                }

                if animationContent {
                    TeamNewsView(size)
                        .foregroundColor(applicationDarkMode ? .white : .black)
                        .opacity(1 - min((-inputTab.scrollProgress * 2), 1))
                        .blur(radius: inputTab.checkBackgroundAnimation ||
                                      !inputTab.showSelectBackground ? 0 : 2)
                        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 20)))
                        .scaleEffect(teamNews.transitionScale)
                        .scaleEffect(teamNews.pressingAnimation ? 1.02 : 1)
                        .offset(teamNews.transitionOffset)
                        .customDragGesture(
                            active: $homeVM.isActiveEdit,
                            transition: $teamNews.transitionOffset,
                            initial: $teamNews.initialOffset
                        )
                        .customMagnificationGesture(
                            active: $homeVM.isActiveEdit,
                            transition: $teamNews.transitionScale,
                            initial: $teamNews.initialScale
                        )
                        .customLongPressGesture(
                            pressing: $teamNews.pressingAnimation,
                            backState: $inputTab.pressingAnimation,
                            perform: $homeVM.isActiveEdit
                        )
                }
            } // VStack
            /// Homeパーツのロングプレスを検知し、親ビューにステートを知らせる
            .frame(width: size.width, height: size.height)
            .overlay {
                if homeVM.isActiveEdit {
                    Text("""
                         位置の調整・・・ドラッグ
                         拡大と縮小・・・ピンチアウト
                         """
                    )
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(5)
                    .offset(y: -size.height / 2 + 60)
                }
            }
            .overlay {
                if homeVM.isActiveEdit {
                    VStack(spacing: 20) {

                        HStack(spacing: 40) {
                            Button {
                                withAnimation(.interactiveSpring(response: 0.7,
                                                                 dampingFraction: 1,
                                                                 blendDuration: 1)) {
                                    nowTime.initialOffset = .zero
                                    nowTime.transitionOffset = .zero
                                    nowTime.initialScale = 1
                                    nowTime.transitionScale = 1

                                    teamNews.initialOffset = .zero
                                    teamNews.transitionOffset = .zero
                                    teamNews.initialScale = 1
                                    teamNews.transitionScale = 1
                                }
                            } label: {
                                Circle()
                                    .fill(.gray.gradient)
                                    .frame(width: 60)
                                    .shadow(radius: 3, x: 3, y: 3)
                                    .shadow(radius: 3, x: 3, y: 3)
                                    .overlay {
                                        Image(systemName: "arrow.counterclockwise")
                                            .foregroundColor(.white)
                                    }
                            }

                            Button {
                                // TODO: 設定をユーザーのjoinTeamデータ内に保存
                                withAnimation(.spring(response: 0.7, blendDuration: 1)) {
                                    homeVM.isActiveEdit = false
                                }
                            } label: {
                                Circle()
                                    .fill(.blue.gradient)
                                    .frame(width: 60)
                                    .shadow(radius: 3, x: 3, y: 3)
                                    .shadow(radius: 3, x: 3, y: 3)
                                    .overlay {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                    }
                            }
                        }

                        Button {
                            //  TODO: パーツを編集前の状態に戻して終了
                            withAnimation(.spring(response: 0.7, blendDuration: 1)) {
                                homeVM.isActiveEdit = false
                            }
                        } label: {
                            Label("キャンセル", systemImage: "xmark.circle.fill")
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                    }
                    .offset(y: size.height / 3)
                }

            }

        }
        .ignoresSafeArea()
    }
    
    // 🕛時刻のレイアウト
    // HStack+Spacerを入れておかないと秒数によって微妙に時計が動いてしまう🤔
    @ViewBuilder
    func NowTimeView(_ homeSize: CGSize) -> some View {

        let partsWidth: CGFloat = 195
        let partsHeight: CGFloat = 110

             VStack {
                GeometryReader {
                    let size = $0.size
                    let rect = $0.frame(in: .global)

                    VStack(alignment: .leading, spacing: 8) {

                        Text(inputTime.hm)
                            .italic()
                            .tracking(8)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                            .opacity(0.8)

                        Text("\(inputTime.week).")
                            .italic()
                            .tracking(5)
                            .font(.subheadline)
                            .opacity(0.8)

                        Text(inputTime.dateStyle)
                            .font(.subheadline)
                            .italic()
                            .tracking(5)
                            .padding(.leading)
                            .opacity(0.8)
                    }
                    .frame(maxWidth: size.width, maxHeight: size.height)
                    .onReceive(inputTime.timer) { _ in
                        inputTime.nowDate = Date()
                    }

                } // GeometryReader
            } // VStack
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .compositingGroup()
                    .shadow(radius: 3, x: 1, y: 1)
                    .opacity(0.8)
                    .opacity(nowTime.backState ? 1 :
                                nowTime.pressingAnimation ? 0.6 :
                                homeVM.isActiveEdit ? 0.1 : 0
                    )
            }
            .frame(width: partsWidth, height: partsHeight)
            .opacity(nowTime.desplayState ? 1 :
                        homeVM.isActiveEdit ? 0.3 : 0
            )
            .overlay(alignment: .topLeading) {
                CustomizeHomePartsButtons(show: homeVM.isActiveEdit,
                                          desplay: $nowTime.desplayState,
                                          back: $nowTime.backState
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: -10, y: -40)
            }
            .position(
                x: partsWidth / 2,
                y: homeSize.height / 2 - 150
            )
    }

    /// チームに関する情報を一覧で表示するHomeパーツ
    @ViewBuilder
    func TeamNewsView(_ homeSize: CGSize) -> some View {

        let partsWidth: CGFloat = 135
        let partsHeight: CGFloat = 240

         VStack {
            GeometryReader {
                let size = $0.size
                let local = $0.frame(in: .local)
                let global = $0.frame(in: .global)

                ZStack {
                    VStack(alignment: .leading, spacing: 60) {

                        Group {
                            Text("Useday.  ")
                            Text("Items.  ")
                            Text("Member.  ")
                        }
                        .font(.footnote)
                        .tracking(5)
                        .opacity(0.8)

                    } // VStack

                    VStack(alignment: .trailing, spacing: 60) {

                        //TODO: 実際の使用日数を計算で割り出す
                        Text("55 day")
                            .font(.footnote)
                            .opacity(0.8)

                        Text("\(itemVM.items.count) item")
                            .font(.footnote)
                            .opacity(0.8)

                        // Team members Icon...
                        teamMembersIcon(members: teamVM.team!.members)
                    }
                    .offset(x: 20, y: 35)
                    .tracking(5)
                } // ZStack
            } // GeometryReader
        } // VStack
        .padding(.top, 10)
        .padding(.leading, 10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .compositingGroup()
                .shadow(radius: 3, x: 1, y: 1)
                .opacity(0.8)
                .opacity(teamNews.backState ? 1 :
                            teamNews.pressingAnimation ? 0.6 :
                            homeVM.isActiveEdit ? 0.1 : 0
                )
        }
        .frame(width: partsWidth, height: partsHeight)
        .opacity(teamNews.desplayState ? 1 :
                    homeVM.isActiveEdit ? 0.3 : 0
        )
        .overlay(alignment: .topLeading) {
            CustomizeHomePartsButtons(show: homeVM.isActiveEdit,
                                      desplay: $teamNews.desplayState,
                                      back: $teamNews.backState
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            .offset(x: -10, y: -40)

        }
        .position(x: homeSize.width - partsWidth / 2)
    }
    @ViewBuilder
    func teamMembersIcon(members: [JoinMember]) -> some View {
        Group {
            if members.count <= 2 {
                HStack {
                    ForEach(members, id: \.self) { member in
                        AsyncImageCircleIcon(photoURL: member.iconURL, size: 30)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(members, id: \.self) { member in
                            AsyncImageCircleIcon(photoURL: member.iconURL, size: 30)
                        }
                    }
                }.frame(width: 80)
            }
        }
    } // teamMembersIcon

}

struct CustomizeHomePartsButtons: View {

    var show: Bool
    @Binding var desplay: Bool
    @Binding var back: Bool

    var body: some View {
        if show {
            HStack(spacing: 10) {
                Button {
                    withAnimation {
                        desplay.toggle()
                    }

                } label: {
                    Circle()
                        .fill(.white.gradient)
                        .frame(width: 30)
                        .shadow(radius: 3, x: 1, y: 1)
                        .overlay {
                            Image(systemName: "wand.and.rays.inverse")
                                .foregroundColor(.gray)
                        }
                }
                .opacity(desplay ? 1 : 0.6)

                Button {
                    withAnimation {
                        back.toggle()
                    }
                } label: {
                    Circle()
                        .fill(.white.gradient)
                        .frame(width: 30)
                        .shadow(radius: 3, x: 1, y: 1)
                        .overlay {
                            Image(systemName: "rectangle.dashed")
                                .foregroundColor(.gray)
                        }
                }
                .opacity(back ? 1 : 0.6)
            }
            .transition(AnyTransition.opacity.combined(with: .offset(y: 20)))
        } // if
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView(itemVM: ItemViewModel(),
                    inputTab: .constant(InputTab()))
        .background {
            Image("background_4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}
