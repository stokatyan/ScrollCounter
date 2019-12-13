//
//  DigitScrollCounter.swift
//  ScrollCounter
//
//  Created by Shant Tokatyan on 12/7/19.
//  Copyright © 2019 Stokaty. All rights reserved.
//

import UIKit

/**
 A subclass of `ScrollableCounter` that is used to scroll through an ordered range of digits.
 */
public class DigitScrollCounter: ScrollableCounter {
    
    /**
     Initialize a `DigitScrollCounter` with the given parameters.
     - note:
     The value of `min` must be less than the value of `max`.
     
     - parameters:
        - min: The minimum value on the digit scroller (it does not have to actually be a a single digit).
        - max: The maximum value on the digit scroller (it does not have to actually be a a single digit).
        - font: The font of all of the labels that will make up the digits.
        - textColor: The textColor of all of the labels that will make up the digits.
        - backgroundColor: The backgroundColor of all of the labels that will make up the digits.
        - scrollDuration:The total time interval for the animations when scrolling between any two digits.
        - gradientColor: The color of the vertical gradient applied to the scroll counter.  If this is `nil`, then no gradient is applied.
        - gradientStop: The stopping point for the gradient, where the bottom stopping point is (1 - gradientStop).  If this is `nil`, then no gradient is applied.
     */
    public init(min: Int = 0, max: Int = 9, font: UIFont, textColor: UIColor, backgroundColor: UIColor, scrollDuration: TimeInterval, gradientColor: UIColor? = nil, gradientStop: Float? = nil) {
        assert(min < max, "The min value must be less than the max value.")
        var labels = [UILabel]()
        
        var i = min
        var biggestFrameHeight: CGFloat = 0
        var biggestFrameWidth: CGFloat = 0
        while i <= max {
            let label = UILabel(frame: CGRect.zero)
            label.text = String(i)
            label.font = font
            label.textAlignment = .center
            label.sizeToFit()
            label.textColor = textColor
            label.backgroundColor = backgroundColor
            
            if label.frame.height > biggestFrameHeight {
                biggestFrameHeight = label.frame.height
            }
            if label.frame.width > biggestFrameWidth {
                biggestFrameWidth = label.frame.width
            }
            
            
            labels.append(label)
            i += 1
        }
        
        let biggestFrame = CGRect(x: 0, y: 0, width: biggestFrameWidth, height: biggestFrameHeight)
        
        var items = [UIView]()
        for label in labels {
            let view = UIView(frame: biggestFrame)
            
            label.frame.origin.x = (biggestFrame.width - label.frame.width)/2
            label.frame.origin.y = (biggestFrame.height - label.frame.height)/2
            view.addSubview(label)
            
            items.append(view)
        }
        
        super.init(items: items, frame: biggestFrame, gradientColor: gradientColor, gradientStop: gradientStop)
        self.scrollDuration = scrollDuration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
