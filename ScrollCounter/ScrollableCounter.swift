//
//  ScrollableCounter.swift
//  ScrollCounter
//
//  Created by Shant Tokatyan on 12/4/19.
//  Copyright © 2019 Stokaty. All rights reserved.
//

import UIKit

/**
 The building block for a `ScrollCounter`.  A `ScrollableCounter` scrolls between a given list of views.
 */
public class ScrollableCounter: UIView {
    
    /// The direction of the scrolling animation.
    public enum ScrollDirection {
        case down
        case up
    
        /// The corresponding shift  to use when cycling the `items` array.
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
    
    /// The views that will be scrolled.
    private let items: [UIView]
    
    /// The index of the currently selected item.
    public private(set) var currentIndex = 0
    /// The item that is currently selected.
    private var currentItem: UIView {
        return items[currentIndex]
    }
    
    /// The animator controlling the current animation in the ScrollableCounter.
    private var animator: UIViewPropertyAnimator?
    /// The subset of elements from `items` that are currently being animated.
    private var itemsBeingAnimated = [UIView]()
    
    /// The total duration of a scroll animation.
    var scrollDuration: TimeInterval = 0
    /// The animation curve for a scroll animation.
    var animationCurve: AnimationCurve = .easeInOut
    
    var gradientView: UIView?
    
    /// The animation duration to use when no animation is desired.
    static let noAnimationDuration: TimeInterval = 0.01
    
    var height: CGFloat {
        return frame.height
    }
    var width: CGFloat {
        return frame.width
    }
    
    // MARK: - Init
    
    /**
     Initialize a `ScrollableCounter` with the list of items to scroll through.
     
     - note:
     A `ScrollableCounter` assumes that each item being scrolled has the same exact frame as the `ScrollableCounter`.
     
     - parameters:
        - items: An ordered list of the views that will be scrolled.
        - frame: The frame of the `ScrollableCounter`, and the frame of every item.
        - gradientColor: The color to use for the vertical gradient.  If this is `nil`, then no gradient is applied.
        - gradientStop: The stopping point for the gradient, where the bottom stopping point is (1 - gradientStop).  If gradientStop is not less than 0.5 than it is ignored.  If this is `nil`, then no gradient is applied.
     */
    init(items: [UIView], frame: CGRect = CGRect.zero, gradientColor: UIColor? = nil, gradientStop: Float? = nil) {
        assert(items.count > 0, "ScrollableCounter must be initialized with non empty array of items.")
        for item in items {
            assert(item.frame.equalTo(frame), "The frame of each item should equal the frame of the ScrollableCounter")
        }
        self.items = items
        super.init(frame: frame)
        clipsToBounds = true
        
        addSubview(currentItem)
        currentItem.frame.origin = CGPoint.zero
        
        for (tag, item) in items.enumerated() {
            item.tag = tag
        }
        
        if let gradientColor = gradientColor, let gradientStop = gradientStop {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = frame
            gradientLayer.colors = [gradientColor.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, gradientColor.cgColor]
            gradientLayer.locations = [0, NSNumber(value: gradientStop), NSNumber(value: 1.0 - gradientStop), 1]
            let view = UIView(frame: frame)
            view.backgroundColor = .clear
            view.layer.addSublayer(gradientLayer)
            addSubview(view)
            bringSubviewToFront(view)
            gradientView = view
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Animation
    
    /**
     Animates `currentItem` to the corresponding item at the given index.
    
     When animating to a new item, each item in between the current and final item gets scrolled through.
     The views that need to be animated through are stacked on top (or botttom, depending on `direction`) of each other and animated accordingly.
     
     At the end of the animation  `index` is set as the new `currentIndex`.
     The `currentIndex` property is updated at the start of every animation to account for animations that were stopped before finishing.
     
     - parameters:
        - index: The index of the item to animate to.
        - animated: Whether or not the scrolling should be animated.
     */
    private func animateToItem(atIndex index: Int, direction: ScrollDirection, animated: Bool) {
        resetCurrentIndex(direction: direction)
        setupItemsToAnimate(atIndex: index, direction: direction)
        
        var animationDuration = scrollDuration
        if !animated {
            animationDuration = ScrollableCounter.noAnimationDuration
        }
        
        let animator = buildAnimations(direction: direction, duration: animationDuration)
        animator.addCompletion { position in
            self.animationCompletion(newCurrentIndex: index)
        }
        
        animator.startAnimation()
        self.animator = animator
    }
    
    /**
     The completion to execute when `animator` finishes running.
     This updates `currentIndex`, `itemsBeingAnimated`, and removes all of the items in `items`  that are not needed from the superview.
     */
    private func animationCompletion(newCurrentIndex index: Int) {
        self.currentIndex = index
        for i in 0..<self.items.count {
            if i != index {
                self.items[i].removeFromSuperview()
            }
        }
        self.itemsBeingAnimated.removeAll()
    }
    
    /**
     Creates a `UIViewPropertyAnimator` and adds the corresponding animations required for each view in `itemsBeingAnimated`.
     - returns: The `UIViewPropertyAnimator` that will be in charge of the the build animations.
     */
    private func buildAnimations(direction: ScrollDirection, duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, curve: animationCurve, animations: nil)
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
        return animator
    }
    
    /**
     Sets up the `itemsBeingAnimated` array with all of the elements that need to be animated, and set the initial position of each element.
     - parameters:
        - direction: The direction of the animation, which effects which views will be animated.
     */
    func setupItemsToAnimate(atIndex index: Int, direction: ScrollDirection) {
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
            
            if itemIndex == index {
                continueBuilding = false
            }
            distance += 1
            itemIndex = (itemIndex + direction.shift) % items.count
            if itemIndex < 0 {
                itemIndex = items.count - 1
            }
        }
        
        if let gradientView = gradientView {
            bringSubviewToFront(gradientView)
        }
    }
    
    // MARK: Control
    
    /**
     Calculates the direction that should be scrolled fore the current state of the scrollable counter to animate to the given index.
     - parameters:
        - index: The index that the scrollable counter should scroll to.
     */
    private func calculateDirection(toIndex index: Int) -> ScrollDirection {
        var direction: ScrollDirection
        var downDistance: Int
        var upDistance: Int
        
        if currentIndex == index {
            if currentItem.top > 0 {
                direction = .up
            } else {
                direction = .down
            }
        } else {
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
        }
        
        return direction
    }
    
    /**
     Removes the elements in `itemsBeingAnimated` that are dangling from their superview, (which is `self`).
    
     An element of `itemsBeingAnimated` is consdered dangling if it is not currently visible but is still a subview of `self`.
     */
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
    
    /**
     Resets what is considered the `currentIndex` based on on the elements in `itemsBeingAnimated` and the direction given.
     - parameters:
        - direction : The direction to the baser the `currentIndex` off of.
     */
    private func resetCurrentIndex(direction: ScrollDirection) {
        guard itemsBeingAnimated.count >= 2 else {
            if let onlyItem = itemsBeingAnimated.first {
                currentIndex = onlyItem.tag
            }
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
    
    /**
     Resets `currentIndex` to the index of the item in `itemsBeingAnimated` that is the most visible.
     */
    func resetCurrentIndexToClosest() {
        guard itemsBeingAnimated.count >= 2 else {
            if let onlyItem = itemsBeingAnimated.first {
                currentIndex = onlyItem.tag
            }
            return
        }
        
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var minDistIndex: Int = 0
        var minDistance2: CGFloat = CGFloat.greatestFiniteMagnitude
        var minDistIndex2: Int = 0
        for (index, item) in itemsBeingAnimated.enumerated() {
            let distance = abs(item.top)
            if distance < minDistance {
                minDistance2 = minDistance
                minDistIndex2 = minDistIndex
                
                minDistance = distance
                minDistIndex = index
            } else if distance < minDistance2 {
                minDistance2 = distance
                minDistIndex2 = index
            }
        }
        
        currentIndex = itemsBeingAnimated[minDistIndex].tag
        let item0 = itemsBeingAnimated[minDistIndex]
        let item1 = itemsBeingAnimated[minDistIndex2]
        itemsBeingAnimated = [item0, item1]
    }
    
    /**
     Scrolls to the item at the given index using the direction that requires the least amount views to be scrolled through.
     If the animated flag is set to `true` then `self.scrollDuration` is ignored and a value of 0 is used for the scroll animation.
     
     - note:
     This will stop any animation that is currently playing.
     
     - parameters:
        - index: The index of the item to scroll to.
        - animated: Whether or not the scrolling should be animated.  Defaults to `true`.
     */
    public func scrollToItem(atIndex index: Int, animated: Bool = true) {
        stop()
        resetCurrentIndexToClosest()
        let direction = calculateDirection(toIndex: index)
    
        animateToItem(atIndex: index, direction: direction, animated: animated)
    }
    
    /**
     Stops the current `animator` (if it is not nil) and then removes all dangling items.
     */
    private func stop() {
        if let animator = animator {
            animator.stopAnimation(true)
        }
        removeDanglingItems()
    }
    
}
