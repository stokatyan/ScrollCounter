//
//  Extensions.swift
//  ScrollCounter
//
//  Created by Shant Tokatyan on 12/4/19.
//  Copyright © 2019 Stokaty. All rights reserved.
//

import UIKit

extension UIView {
 
    func move(to destination: CGPoint,
              duration: TimeInterval,
              options: UIView.AnimationOptions,
              completion: @escaping () -> Void) {
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: options,
                       animations:
        {
            self.frame.origin = destination
        }) { finished in
            completion()
        }
    }
    
}
