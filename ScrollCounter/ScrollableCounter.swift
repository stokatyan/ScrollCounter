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
    
        var shift: Int {
            switch self {
            case .down:
                return 1
            case .up:
                return -1
            }
        }
    }
    
    // MARK: - Properties
    
    let items: [UIView]
    private var currentIndex = 0
    private var currentItem: UIView {
        return items[currentIndex]
    }
    
    private var animator: UIViewPropertyAnimator?
    private var latestDirection: ScrollDirection?
    var totalDuration: TimeInterval = 1
    
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
    
    private func normalize(direction: ScrollDirection, duration: TimeInterval, completion: (() -> Void)?) {
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
        
//        showNextItem(direction, duration: duration) {
//            self.showNextItem(direction, duration: duration, completion: completion)
//        }
    }
    
    private func animateToItem(atIndex index: Int, direction: ScrollDirection) {
        let animator = UIViewPropertyAnimator(duration: totalDuration, curve: .linear, animations: nil)
        
        var itemsToAnimate = [UIView]()
        
        var itemIndex = currentIndex
        var distance = 0
        var continueBuilding = true
        while continueBuilding {
            let item = items[itemIndex]
            if distance != 0 {
                addSubview(item)
                switch direction {
                case .down:
                    item.frame.origin = CGPoint(x: 0, y: frame.height * CGFloat(distance) * -1)
                case .up:
                    item.frame.origin = CGPoint(x: 0, y: frame.height * CGFloat(distance))
                }
            }
            itemsToAnimate.append(item)
                        
            if itemIndex == index {
                continueBuilding = false
            }
            distance += 1
            itemIndex = (itemIndex + direction.shift) % items.count
            if itemIndex < 0 {
                itemIndex = items.count - 1
            }
        }
        
        for (i, item) in itemsToAnimate.enumerated() {
            let diff = CGFloat(itemsToAnimate.count - (i + 1))
            animator.addAnimations {
                switch direction {
                case .down:
                    item.frame.origin = CGPoint(x: 0, y: diff * self.frame.height)
                case .up:
                    item.frame.origin = CGPoint(x: 0, y: diff * self.frame.height * -1)
                }
            }
        }
        
        animator.addCompletion { position in
            self.currentIndex = index
            for i in 0..<self.items.count {
                if i != index {
                    self.items[i].removeFromSuperview()
                }
            }
        }
        
        animator.startAnimation()
        self.animator = animator
        
    }
    
//    private func showNextItem(_ direction: ScrollDirection, duration: TimeInterval, completion: (() -> Void)?) {
//        if let latestDirection = latestDirection, latestDirection != direction, currentItem.frame.origin != CGPoint.zero {
//            let currentProgress = abs(currentItem.top - currentItem.frame.height) / currentItem.frame.height
//            let normalizeDuration = duration * TimeInterval(1 - currentProgress)
//            normalize(direction: direction, duration: normalizeDuration, completion: completion)
//            return
//        }
//        latestDirection = direction
//
//        var currentItemEndY = -currentItem.frame.height
//        var nextItemStartPoint = CGPoint(x: 0, y: currentItem.bottom)
//        let nextItemEndPoint = CGPoint.zero
//        var nextItemShift = -1
//
//        if direction == .down {
//            currentItemEndY = currentItem.frame.height
//            nextItemStartPoint = CGPoint(x: 0, y: currentItem.top - currentItem.frame.height)
//            nextItemShift = 1
//        }
//
//        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: nil)
//
//        animator.addAnimations {
//            self.currentItem.frame.origin = CGPoint(x: 0, y: currentItemEndY)
//        }
//
//        var nextItemIndex = (currentIndex + nextItemShift) % items.count
//        if nextItemIndex < 0 {
//            nextItemIndex = items.count - 1
//        }
//
//        let nextItem = items[nextItemIndex]
//        nextItem.frame.origin = nextItemStartPoint
//        addSubview(nextItem)
//        animator.addAnimations {
//            nextItem.frame.origin = nextItemEndPoint
//        }
//
//        animator.addCompletion { position in
//            if let completion = completion {
//                self.currentItem.removeFromSuperview()
//                self.currentIndex = nextItemIndex
//                completion()
//            }
//        }
//
//        animator.startAnimation()
//        self.animator = animator
//    }
    
    public func scrollToItem(atIndex index: Int) {
        stop()
        var direction: ScrollDirection
        
        var downDistance: Int
        var upDistance: Int
        
        if index > currentIndex {
            downDistance = index - currentIndex
        } else {
            downDistance = items.count - abs(currentIndex - index)
        }
        
        if index < currentIndex {
            upDistance = currentIndex - index
        } else {
            upDistance = items.count - abs(currentIndex - index)
        }
        
        if downDistance < upDistance {
            direction = .down
        } else if upDistance < downDistance {
            direction = .up
        } else {
            direction = .down
            if index < currentIndex {
                direction = .up
            }
        }
        
//        scrollToItem(atIndex: index, direction: direction)
        animateToItem(atIndex: index, direction: direction)
    }
    
//    public func scrollToItem(atIndex index: Int, direction: ScrollDirection) {
//        guard index != currentIndex else {
//            return
//        }
//        var nTimes: Int = 0
//
//        switch direction {
//        case .down:
//            if index > currentIndex {
//                nTimes = index - currentIndex
//            } else {
//                nTimes = items.count - currentIndex + index
//            }
//        case .up:
//            if index < currentIndex {
//                nTimes = currentIndex - index
//            } else {
//                nTimes = items.count + currentIndex - index
//            }
//        }
//
//        scrollNext(direction, nTimes: nTimes)
//    }
//
//    public func scrollNext(_ direction: ScrollDirection, nTimes: Int) {
//        guard nTimes > 0 else {
//            return
//        }
//
//        self.scrollNext(direction, durationPerItem: totalDuration/TimeInterval(nTimes), nTimes: nTimes)
//    }
//
//    func scrollNext(_ direction: ScrollDirection, durationPerItem duration: TimeInterval, nTimes: Int) {
//        guard nTimes > 0 else {
//            return
//        }
//
//        showNextItem(direction, duration: duration) {
//            self.scrollNext(direction, durationPerItem: duration, nTimes: nTimes - 1)
//        }
//    }
    
    public func stop() {
        if let animator = animator {
            animator.stopAnimation(true)
        }
    }
    
    
}
