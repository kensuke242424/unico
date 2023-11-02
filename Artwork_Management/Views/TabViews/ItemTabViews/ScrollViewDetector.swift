//
//  ScrollViewDetector.swift
//  Artwork_Management
//
//  Created by Kensuke Nakagawa on 2023/03/15.
//

import SwiftUI

struct ScrollViewDetector: UIViewRepresentable {
    
    @Binding var carouselMode: Bool
    var totalContent: Int = 0
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView {
                scrollView.decelerationRate = carouselMode ? .fast : .normal
                if carouselMode {
                    scrollView.delegate = context.coordinator
                } else {
                    scrollView.delegate = nil
                }
                
                /// Updateing Total Count in real time -リアルタイムで総カウント数を更新する-
                context.coordinator.totalContent = totalContent
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ScrollViewDetector
        init(parent: ScrollViewDetector) {
            self.parent = parent
        }
        
        var totalContent: Int = 0
        var velocityY: CGFloat = 0
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            /// Removing Invalid Scroll Position's -無効なスクロール位置の削除-
            let cardHeight: CGFloat = 220
            let cardSpacing: CGFloat = 35
            /// Adding velocity for more natural feel -ベロシティを追加して、より自然な感じを出す-
            let targetEnd: CGFloat = scrollView.contentOffset.y + (velocity.y * 60)
            let index = (targetEnd / cardHeight).rounded()
            let modifiedEnd = index * cardHeight
            let spacing = cardSpacing * index
            
            targetContentOffset.pointee.y = modifiedEnd + spacing
            velocityY = velocity.y
            
        }
        
        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            /// Removing Invalid Scroll Position's -無効なスクロール位置の削除-
            let cardHeight: CGFloat = 220
            let cardSpacing: CGFloat = 35
            /// Adding velocity for more natural feel -ベロシティを追加して、より自然な感じを出す-
            let targetEnd: CGFloat = scrollView.contentOffset.y + (velocityY * 60)
            let index = max(min((targetEnd / cardHeight).rounded(), CGFloat(totalContent - 1)), 0.0)
            let modifiedEnd = index * cardHeight
            let spacing = cardSpacing * index
            
            scrollView.setContentOffset(.init(x: 0, y: modifiedEnd + spacing), animated: true)
        }
    }
}

