//
//  HomeTabView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct NewHomeView: View {
    
    @EnvironmentObject var teamVM: TeamViewModel
    @StateObject var itemVM: ItemViewModel
    
    /// Tab親Viewから受け取った状態変数群
    @Binding var inputTab: InputTab
    
    @State private var inputTime = InputTimesView()
    @State private var animationContent: Bool = true
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                if animationContent {
                    NowTimeView(size)
                        .opacity(1 - min((-inputTab.scrollProgress * 2), 1))
                        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 20)))
                }
                
                if animationContent {
                    TeamView(size)
                        .opacity(1 - min((-inputTab.scrollProgress * 2), 1))
                        .transition(AnyTransition.opacity.combined(with: .offset(x: 0, y: 20)))
                }
                
            } // VStack
            .frame(width: size.width, height: size.height)
            .offset(y: -50)
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
            .onReceive(inputTime.timer) { _ in
                inputTime.nowDate = Date()
            }
            Spacer()
        } // HStack
        .frame(maxWidth: .infinity)
        .padding(.trailing, size.width / 2)
        .padding([.leading, .bottom], 15)
    }
    
    func TeamView(_ size: CGSize) -> some View {
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
        } // HStack
        .padding(.trailing, 20)
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
