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
    
    // MARK: Properties
    
    let items: [UIView]
    private var currentIndex = 0
    private var currentItem: UIView? {
        if currentIndex < items.count {
            return items[currentIndex]
        }
        return nil
    }
    
    let scrollDuration: TimeInterval = 1
    
    // MARK: Init
    
    public init(items: [UIView], frame: CGRect = CGRect.zero) {
        self.items = items
        super.init(frame: frame)
        clipsToBounds = true
        
        guard let currentItem = currentItem else {
            return
        }
        
        addSubview(currentItem)
        currentItem.frame.origin = CGPoint.zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    public func showNextItem(completion: (() -> Void)?) {
        if let currentItem = currentItem {
            currentItem.move(to: CGPoint(x: 0, y: -currentItem.frame.height),
                             duration: scrollDuration,
                             options: .curveLinear) {}
        }
        
        let nextItemIndex = (currentIndex + 1) % items.count
        let nextItem = items[nextItemIndex]
        nextItem.frame.origin = CGPoint(x: 0, y: frame.height)
        addSubview(nextItem)
        nextItem.move(to: CGPoint.zero,
                      duration: scrollDuration,
                      options: .curveLinear)
        {
            if let completion = completion {
                self.currentIndex = nextItemIndex
                completion()
            }
        }
    }
    
    public func scrollNext(nTimes: Int) {
        guard nTimes > 0 else {
            return
        }
        showNextItem {
            self.scrollNext(nTimes: nTimes - 1)
        }
    }
    
}
