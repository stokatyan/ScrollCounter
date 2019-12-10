//
//  Extensions.swift
//  ScrollCounter
//
//  Created by Shant Tokatyan on 12/5/19.
//  Copyright © 2019 Stokaty. All rights reserved.
//

import UIKit

extension UIView {
    
    var bottom: CGFloat {
        return frame.origin.y + frame.height
    }
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    func animateIn() {
        
    }
    
}


extension Float {
    func round(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
