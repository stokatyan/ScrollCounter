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
    
    public private(set) var currentValue: Float
    
    var decimalPlaces: Int = 0
    let font: UIFont
    let textColor: UIColor
    let digitBackgroundColor: UIColor
    
    var prefix: String?
    var suffix: String?
    var seperator: String
    let negativeSign = "-"
    
    private var prefixView: UIView?
    private var suffixView: UIView?
    private var seperatorView: UIView?
    private var negativeSignView: UIView?
    
    /// The animator controlling the current animation in the ScrollableCounter.
    private var animator: UIViewPropertyAnimator?
    
    /// The animation curve for a scroll animation.
    var animationCurve: AnimationCurve = .easeInOut
    
    // MARK: - Init
    
    public init(value: Float, decimalPlaces: Int = 0, prefix: String? = nil, suffix: String? = nil, seperator: String = ".", font: UIFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize), textColor: UIColor = .black, digitBackgroundColor: UIColor = .clear) {

        self.currentValue = value
        
        self.decimalPlaces = decimalPlaces
        self.font = font
        self.textColor = textColor
        self.digitBackgroundColor = digitBackgroundColor
        
        self.prefix = prefix
        self.suffix = suffix
        self.seperator = seperator
        
        super.init(frame: CGRect.zero)
        
        self.clipsToBounds = false
        
        setValue(value)
        frame.size.height = digitScrollers.first!.height
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Control
    
    public func setValue(_ value: Float) {
        currentValue = value.round(toPlaces: decimalPlaces)
        
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
        updateScrollerLayout()
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
        if let animator = self.animator {
            animator.stopAnimation(true)
        }
        animator = UIViewPropertyAnimator(duration: scrollDuration, curve: animationCurve, animations: nil)
        
        let includeNegativeSign = currentValue < 0
        print(includeNegativeSign)
        
        if includeNegativeSign {
            if let negativeSignView = negativeSignView, negativeSignView.alpha != 1 {
                animator!.addAnimations {
                    negativeSignView.alpha = 1
                }
            } else if negativeSignView == nil {
                let negativeLabel = UILabel()
                negativeLabel.text = negativeSign
                negativeLabel.textColor = textColor
                negativeLabel.font = font
                negativeLabel.sizeToFit()
                negativeLabel.frame.origin = CGPoint.zero
                addSubview(negativeLabel)
                
                negativeLabel.alpha = 0
                negativeSignView = negativeLabel
                animator!.addAnimations {
                    negativeLabel.alpha = 1
                }
            }
        } else {
            if let negativeSignView = negativeSignView {
                animator!.addAnimations {
                    negativeSignView.alpha = 0
                }
                animator!.addCompletion { _ in
                    negativeSignView.removeFromSuperview()
                    self.negativeSignView = nil
                }
            }
        }
        
        if prefixView == nil, let prefix = prefix {
            let prefixLabel = UILabel()
            prefixLabel.text = prefix
            prefixLabel.textColor = textColor
            prefixLabel.font = font
            prefixLabel.sizeToFit()
            prefixLabel.frame.origin = CGPoint.zero
            addSubview(prefixLabel)

            prefixLabel.alpha = 0
            prefixView = prefixLabel
        }

        if let prefixView = self.prefixView {
            var prefixX: CGFloat = 0
            if let negativeSignView = negativeSignView, includeNegativeSign {
                prefixX = negativeSignView.frame.width
            }
            animator!.addAnimations {
                prefixView.frame.origin.x = prefixX
                prefixView.alpha = 1
            }
        }
        
        var startingX: CGFloat = 0
        if let prefixView = prefixView {
            startingX += prefixView.frame.width
        }
        if let negativeSignView = negativeSignView, includeNegativeSign {
            startingX += negativeSignView.frame.width
        }
        
        for (index, scroller) in digitScrollers.enumerated() {
            if scroller.superview == nil {
                addSubview(scroller)
                scroller.frame.origin.x = startingX
                scroller.alpha = 0
            }
            animator!.addAnimations {
                scroller.alpha = 1
                scroller.frame.origin.x = startingX + CGFloat(index) * scroller.width
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
            newScrollers.append(DigitScrollCounter(font: font, textColor: textColor, backgroundColor: digitBackgroundColor))
        }
        digitScrollers.insert(contentsOf: newScrollers, at: 0)
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
    }
    
    private func updateScrollers(withDigits digits: [Int]) {
        if digits.count == digitScrollers.count {
            for (i, scroller) in digitScrollers.enumerated() {
                scroller.scrollToItem(atIndex: digits[i])
            }
        }
    }
}
