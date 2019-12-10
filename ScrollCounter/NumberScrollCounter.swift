//
//  NumberScrollCounter.swift
//  ScrollCounter
//
//  Created by Shant Tokatyan on 12/7/19.
//  Copyright © 2019 Stokaty. All rights reserved.
//

import UIKit

public class NumberScrollCounter: UIView {
    
    // MARK: - Parameters
    
    private var digitScrollers = [DigitScrollCounter]()
    var scrollDuration: TimeInterval = 0.5
    var fadeOutDuration: TimeInterval = 0.2
    
    var currentValue: Float
    
    let decimalPlaces: Int
    let font: UIFont
    let textColor: UIColor
    
    let prefix: String
    let suffix: String
    let seperator: String
    
    /// The animator controlling the current animation in the ScrollableCounter.
    private var animator: UIViewPropertyAnimator?
    
    /// The animation curve for a scroll animation.
    var animationCurve: AnimationCurve = .easeInOut
    
    // MARK: - Init
    
    public init(value: Float, decimalPlaces: Int = 0, prefix: String = "", suffix: String = "", seperator: String = ".", font: UIFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize), textColor: UIColor = .black, backgroundColor: UIColor = .clear) {

        self.currentValue = value
        
        self.decimalPlaces = decimalPlaces
        self.font = font
        self.textColor = textColor
        
        self.prefix = prefix
        self.suffix = suffix
        self.seperator = seperator
        
        super.init(frame: CGRect.zero)
        self.backgroundColor = backgroundColor
        self.clipsToBounds = false
        
        setValue(value)
        frame.size.height = digitScrollers.first!.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Control
    
    public func setValue(_ value: Float) {
        currentValue = round(value)
        
        var digitString = getStringArray(fromValue: currentValue)
        if decimalPlaces == 0 {
            while let lastElement = digitString.popLast(), lastElement != seperator {
                continue
            }
        }
        
        var digitsOnly = [Int]()
        for entry in digitString {
            if let value = Int(entry) {
                digitsOnly.append(value)
            }
        }
     
        if digitsOnly.count > digitScrollers.count {
            updateScrollers(add: digitsOnly.count - digitScrollers.count)
        } else if digitScrollers.count > digitsOnly.count {
            updateScrollers(remove: digitScrollers.count - digitsOnly.count)
        }
        
        updateScrollers(withDigits: digitsOnly)
    }
    
    private func getStringArray(fromValue value: Float) -> [String] {
        return String(value).compactMap { character -> String in
            var entry = seperator
            let result = character.wholeNumberValue
            if let resultNumber = result {
                entry = "\(resultNumber)"
            }
            return entry
        }
    }
        
    
    // MARK: - Scroller Updates
    
    private func updateScrollerLayout() {
        if animator != nil {
            animator!.stopAnimation(true)
        }
        animator = UIViewPropertyAnimator(duration: scrollDuration, curve: animationCurve, animations: nil)
        
        for (index, scroller) in digitScrollers.enumerated() {
            var animateIn = false
            if scroller.superview == nil {
                addSubview(scroller)
                scroller.alpha = 0
                animateIn = true
            }
            animator!.addAnimations {
                if animateIn {
                    scroller.alpha = 1
                }
                scroller.frame.origin.x = CGFloat(index) * scroller.width
            }
        }
        
        animator!.addCompletion({ _ in
            self.animator = nil
        })
        
        animator!.startAnimation()
    }
    
    private func updateScrollers(add count: Int) {
        var newScrollers = [DigitScrollCounter]()
        for _ in 0..<count {
            newScrollers.append(DigitScrollCounter(font: font, textColor: textColor, backgroundColor: backgroundColor!))
        }
        digitScrollers.insert(contentsOf: newScrollers, at: 0)
        
        updateScrollerLayout()
    }
    
    private func updateScrollers(remove count: Int) {
        for index in 0..<count {
            let scroller = digitScrollers[0]
            let leftShift = CGFloat(index) * scroller.frame.width * -1
            
            digitScrollers.remove(at: 0)
            UIView.animate(withDuration: fadeOutDuration, delay: 0, options: .curveEaseInOut, animations: {
                scroller.alpha = 0
                scroller.frame.origin.x += leftShift
            }) { _ in
                scroller.removeFromSuperview()
            }
        }
        
        updateScrollerLayout()
    }
    
    private func updateScrollers(withDigits digits: [Int]) {
        if digits.count == digitScrollers.count {
            for (i, scroller) in digitScrollers.enumerated() {
                scroller.scrollToItem(atIndex: digits[i])
            }
        }
    }
}
