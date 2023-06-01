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
    }

    private struct TeamNewsParts {
        var transitionOffset: CGSize = .zero
        var initialOffset: CGSize = .zero
        var transitionScale: CGFloat = 1.0
        var initialScale: CGFloat = 1.0
    }

    @EnvironmentObject var teamVM: TeamViewModel
    @StateObject var itemVM: ItemViewModel

    /// Tab親Viewから受け取った状態変数群
    @Binding var inputTab: InputTab
    
    @State private var inputTime = InputTimesView()

    /// View Property
    @State private var animationContent: Bool = true
    @State private var nowTime = NowTimeParts()
    @State private var teamNews = TeamNewsParts()

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
                        .offset(nowTime.transitionOffset)
                        .customDragGesture(
                            active: $inputTab.isActiveEditHome,
                            transition: $nowTime.transitionOffset,
                            initial: $nowTime.initialOffset
                        )
                        .customMagnificationGesture(
                            active: $inputTab.isActiveEditHome,
                            transition: $nowTime.transitionScale,
                            initial: $nowTime.initialScale
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
                        .offset(teamNews.transitionOffset)
                        .customDragGesture(
                            active: $inputTab.isActiveEditHome,
                            transition: $teamNews.transitionOffset,
                            initial: $teamNews.initialOffset
                        )
                        .customMagnificationGesture(
                            active: $inputTab.isActiveEditHome,
                            transition: $teamNews.transitionScale,
                            initial: $teamNews.initialScale
                        )
                }
                
            } // VStack
            .frame(width: size.width, height: size.height)
            .offset(y: -50)
            .overlay {
                Button("編集する") {
                    withAnimation {
                        inputTab.isActiveEditHome.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)
                .offset(y: size.height / 3)
            }
        }
        .ignoresSafeArea()
    }
    
    // 🕛時刻のレイアウト
    // HStack+Spacerを入れておかないと秒数によって微妙に時計が動いてしまう🤔
    func NowTimeView(_ size: CGSize) -> some View {
        HStack {

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
                } // VStack
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .onReceive(inputTime.timer) { _ in
                    inputTime.nowDate = Date()
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                        .compositingGroup()
                        .shadow(color: .black, radius: 3, x: 1, y: 1)
                }
                .contextMenu {
                    Button(inputTab.isActiveEditHome ? "編集を終了" : "Homeを編集する") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                inputTab.isActiveEditHome.toggle()
                            }
                        }
                    }
                    Button("非表示") {

                    }
                }

            Spacer()

        } // HStack
        .frame(maxWidth: .infinity)
        .padding(.trailing, size.width / 2)

    }
    
    func TeamNewsView(_ size: CGSize) -> some View {
        // チーム情報一覧
        HStack {
            Spacer()

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
            .padding(.top, 10)
            .padding(.bottom, 45)
            .padding(.leading, 10)
            .padding(.trailing, 15)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                    .compositingGroup()
                    .shadow(color: .black, radius: 3, x: 1, y: 1)
            }
            .contextMenu {
                Button(inputTab.isActiveEditHome ? "編集を終了" : "Homeを編集する") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            inputTab.isActiveEditHome.toggle()
                        }
                    }
                }
                Button("非表示") {

                }
            }

        } // HStack
//        .padding(.trailing, 20)
    }
    
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
