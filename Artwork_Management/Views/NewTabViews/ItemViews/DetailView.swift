//
//  DetailView.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct DetailView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var show: Bool
    var animation: Namespace.ID
    var book: Book
    /// View Properties
    @State private var animationContent: Bool = false
    @State private var offsetAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            Button {
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    offsetAnimation = false
                }
                
                /// Closing Detail View
                withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                    animationContent = false
                    
                }
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                        show.toggle()
                    }
//                }
                
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .contentShape(Rectangle())
            }
            .padding([.leading, .vertical], 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(animationContent ? 1 : 0)
            
            /// Book Preview (with Matched Geometry Effect)
            GeometryReader {
                let size = $0.size
                
                HStack(spacing: 20) {
                    Image(book.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: (size.width - 30) / 2, height: size.height)
                        .clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 20))
                        /// Matched Geometry ID
                        .transition(.opacity)
                        .matchedGeometryEffect(id: book.id, in: animation)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text(": \(book.author)")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        RatingView(rating: book.rating)
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 30)
                    .offset(y: offsetAnimation ? 0 : 50)
                    .opacity(offsetAnimation ? 1 : 0)
                }
            }
            .frame(height: 220)
            .zIndex(1)
            
            Rectangle()
                .fill(.gray.opacity(0.05))
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    BookDetails()
                }
                .padding(.leading, 30)
                .padding(.top, -180)
                .zIndex(0)
                .opacity(animationContent ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle()
                .fill(colorScheme == .light ? .white : .black)
                .ignoresSafeArea()
                .opacity(show ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animationContent = true
            }
            
            withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                offsetAnimation = true
            }
        }
    }
    @ViewBuilder
    func BookDetails() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
                Button {
                    
                } label: {
                    Label("Reviews", systemImage: "text.alignleft")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    
                } label: {
                    Label("Like", systemImage: "suit.heart")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider()
                .padding(.vertical, 25)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    Text("About the book")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    /// Detail
                    Text("① 書きもの。書き付け。書類。ぶんしょ。もんぞ。※性霊集‐五（835頃）為大使与福州観察使書「州使責以二文書一、疑二彼腹心一」※宇津保（970‐999頃）藤原の君「かくのごとく人の嘆きをのぞき給はば、人の嘆き願ひみつべし、となん、もんしょに言へる」")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            Button {
                
            } label: {
                Label("編集", systemImage: "pencil.line")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 45)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(Color.red.gradient)
                    }
                    .foregroundColor(.white)
            }
            .padding(.bottom, 15)
        }
        .padding(.top, 180)
        .padding([.horizontal, .top], 15)
        /// Applying Offset Animation
        .offset(y: offsetAnimation ? 0 : 50)
        .opacity(offsetAnimation ? 1 : 0)
    }
}

struct DetailView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        DetailView(show: .constant(true),
                   animation: animation,
                   book: sampleBooks.first!)
    }
}
