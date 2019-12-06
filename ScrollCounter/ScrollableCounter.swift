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
        case fromTop
        case fromBottom
    }
    
    // MARK: - Properties
    
    let items: [UIView]
    private var currentIndex = 0
    private var currentItem: UIView {
        return items[currentIndex]
    }
    
    public var scrollDuration: TimeInterval = 0.75
        
    private var animator: UIViewPropertyAnimator?
    
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
    
    public func showNextItem(completion: (() -> Void)?) {
        
        let progress = TimeInterval((abs(currentItem.top) - currentItem.frame.height)/currentItem.frame.height)
        let duration: TimeInterval =  abs(progress) * scrollDuration
        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: nil)
        
        animator.addAnimations {
            self.currentItem.frame.origin = CGPoint(x: 0, y: -self.currentItem.frame.height)
        }
        
        let nextItemIndex = (currentIndex + 1) % items.count
        let nextItem = items[nextItemIndex]
        nextItem.frame.origin = CGPoint(x: 0, y: currentItem.bottom)
        addSubview(nextItem)
        animator.addAnimations {
            nextItem.frame.origin = CGPoint.zero
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
    
    public func scrollNext(nTimes: Int) {
        guard nTimes > 0 else {
            return
        }
        
        showNextItem {
            self.scrollNext(nTimes: nTimes - 1)
        }
    }
    
    public func stop() {
        if let animator = animator {
            animator.stopAnimation(true)
        }
    }
    
    
}
