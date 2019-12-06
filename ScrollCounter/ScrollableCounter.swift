//
//  ScrollableCounter.swift
//  ScrollCounter
//
//  Created by Shant Tokatyan on 12/4/19.
//  Copyright © 2019 Stokaty. All rights reserved.
//

import UIKit



public class ScrollableCounter: UIView {
    
    public enum ScrollDirection {
        case down
        case up
    }
    
    // MARK: - Properties
    
    let items: [UIView]
    private var currentIndex = 0
    private var currentItem: UIView {
        return items[currentIndex]
    }
    
    public var scrollDuration: TimeInterval = 0.25
    private var animator: UIViewPropertyAnimator?
    private var latestDirection: ScrollDirection?
    
    // MARK: - Init
    
    public init(items: [UIView], frame: CGRect = CGRect.zero) {
        assert(items.count > 0, "ScrollableCounter must be initialized with non empty array of items.")
        self.items = items
        super.init(frame: frame)
        clipsToBounds = true
        
        addSubview(currentItem)
        currentItem.frame.origin = CGPoint.zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scrolling
    
    private func normalize(direction: ScrollDirection, completion: (() -> Void)?) {
        latestDirection = direction
        
        switch direction {
        case .down:
            currentIndex -= 1
            if currentIndex < 0 {
                currentIndex = items.count - 1
            }
        case .up:
            currentIndex = (currentIndex + 1) % items.count
        }
        
        showNextItem(direction, completion: completion)
    }
    
    private func showNextItem(_ direction: ScrollDirection, completion: (() -> Void)?) {
        if let latestDirection = latestDirection, latestDirection != direction {
            normalize(direction: direction, completion: completion)
            return
        }
        latestDirection = direction
        
        let currentItemStartY = currentItem.top
        var currentItemEndY = -currentItem.frame.height
        var nextItemStartPoint = CGPoint(x: 0, y: currentItem.bottom)
        let nextItemEndPoint = CGPoint.zero
        var nextItemShift = -1
        
        if direction == .down {
            currentItemEndY = currentItem.frame.height
            nextItemStartPoint = CGPoint(x: 0, y: currentItem.top - currentItem.frame.height)
            nextItemShift = 1
        }
        
        let progress = TimeInterval((abs(currentItemStartY) - abs(currentItemEndY))/currentItemEndY)
        let duration: TimeInterval =  abs(progress) * scrollDuration
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: nil)
        
        animator.addAnimations {
            self.currentItem.frame.origin = CGPoint(x: 0, y: currentItemEndY)
        }
        
        var nextItemIndex = (currentIndex + nextItemShift) % items.count
        if nextItemIndex < 0 {
            nextItemIndex = items.count - 1
        }
        
        let nextItem = items[nextItemIndex]
        nextItem.frame.origin = nextItemStartPoint
        addSubview(nextItem)
        animator.addAnimations {
            nextItem.frame.origin = nextItemEndPoint
        }
        
        animator.addCompletion { position in
            if let completion = completion {
                self.currentIndex = nextItemIndex
                completion()
            }
        }
        
        animator.startAnimation()
        self.animator = animator
    }
    
    public func scrollNext(_ direction: ScrollDirection = .up, nTimes: Int) {
        guard nTimes > 0 else {
            return
        }
        
        showNextItem(direction) {
            self.scrollNext(direction, nTimes: nTimes - 1)
        }
    }
    
    public func stop() {
        if let animator = animator {
            animator.stopAnimation(true)
        }
    }
    
    
}
