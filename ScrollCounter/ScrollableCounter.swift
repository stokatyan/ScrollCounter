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
    
    var itemsBeingAnimated = [UIView]()
    
    private var animator: UIViewPropertyAnimator?
    private var latestDirection: ScrollDirection?
    var totalDuration: TimeInterval = 0.25
    
    // MARK: - Init
    
    public init(items: [UIView], frame: CGRect = CGRect.zero) {
        assert(items.count > 0, "ScrollableCounter must be initialized with non empty array of items.")
        self.items = items
        super.init(frame: frame)
        clipsToBounds = true
        
        addSubview(currentItem)
        currentItem.frame.origin = CGPoint.zero
        
        for (tag, item) in items.enumerated() {
            item.tag = tag
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scrolling
    
    private func animateToItem(atIndex index: Int, direction: ScrollDirection) {
        resetCurrentIndex(direction: direction)
        let animator = UIViewPropertyAnimator(duration: totalDuration, curve: .linear, animations: nil)
                
        var offset: CGFloat = 0
        var itemIndex = currentIndex
        var distance = 0
        var continueBuilding = true
        while continueBuilding {
            let item = items[itemIndex]
            let isAlreadyBeingAnimated = itemsBeingAnimated.contains(item)
            if isAlreadyBeingAnimated {
                if distance == 0 {
                    offset = item.frame.origin.y
                }
            } else {
                addSubview(item)
            }
            
            switch direction {
            case .down:
                item.frame.origin = CGPoint(x: 0, y: frame.height * CGFloat(distance) * -1)
            case .up:
                item.frame.origin = CGPoint(x: 0, y: frame.height * CGFloat(distance))
            }
            item.frame.origin.y += offset
            
            if !isAlreadyBeingAnimated {
                itemsBeingAnimated.append(item)
            }
            
            // prepare next iteration
            if itemIndex == index {
                continueBuilding = false
            }
            distance += 1
            itemIndex = (itemIndex + direction.shift) % items.count
            if itemIndex < 0 {
                itemIndex = items.count - 1
            }
        }
        
        for (i, item) in itemsBeingAnimated.enumerated() {
            let diff = CGFloat(itemsBeingAnimated.count - (i + 1))
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
            self.itemsBeingAnimated.removeAll()
        }
        
        animator.startAnimation()
        self.animator = animator
        
    }
    
    public func scrollToItem(atIndex index: Int) {
        stop()
        resetClosestIndex()
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
        
        animateToItem(atIndex: index, direction: direction)
    }
    
    private func removeDanglingItems() {
        for item in itemsBeingAnimated {
            if abs(item.frame.origin.y) >= frame.height {
                item.removeFromSuperview()
            }
        }
        
        itemsBeingAnimated.removeAll { item -> Bool in
            return item.superview == nil
        }
    }
    
    private func resetCurrentIndex(direction: ScrollDirection) {
        guard itemsBeingAnimated.count == 2 else {
            return
        }
        let item0 = itemsBeingAnimated[0]
        let item1 = itemsBeingAnimated[1]
        
        switch direction {
        case .down:
            if item0.top > 0 {
                currentIndex = item0.tag
            } else {
                currentIndex = item1.tag
            }
        case .up:
            if item0.top < 0 {
                currentIndex = item0.tag
            } else {
                currentIndex = item1.tag
            }
        }
        
        if currentIndex == item0.tag {
            itemsBeingAnimated = [item0, item1]
        } else {
            itemsBeingAnimated = [item1, item0]
        }
        
    }
    
    func resetClosestIndex() {
        guard itemsBeingAnimated.count == 2 else {
            return
        }
        let item0 = itemsBeingAnimated[0]
        let item1 = itemsBeingAnimated[1]
        
        if abs(item0.top) < abs(item0.top) {
            currentIndex = item0.tag
        } else {
            currentIndex = item1.tag
        }
        
        if currentIndex == item0.tag {
            itemsBeingAnimated = [item0, item1]
        } else {
            itemsBeingAnimated = [item1, item0]
        }
    }
    
    public func stop() {
        if let animator = animator {
            animator.stopAnimation(true)
        }
        removeDanglingItems()
    }
    
    
    
}
