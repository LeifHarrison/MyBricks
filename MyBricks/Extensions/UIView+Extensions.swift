//
//  UIView+Extensions.swift
//  MyBricks
//
//  Created by Leif on 11/20/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

extension UIView {
    
    func constrainToView(view: UIView) {
        let top = self.topAnchor.constraint(equalTo: view.topAnchor)
        let bottom = view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let leading = self.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing = view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
    }
    
    func fadeIn(duration: TimeInterval = 0.3) {
        if isHidden == false, alpha == 1.0 { return }
        
        self.alpha = 0.0
        self.isHidden = false
        
        let animations: (() -> Void) = {
            self.alpha = 1.0
        }
        UIView.animate(withDuration: duration, animations: animations, completion: nil)
    }
    
    func fadeOut(duration: TimeInterval = 0.3) {
        if isHidden { return }

        let animations: (() -> Void) = {
            self.alpha = 0.0
        }
        let completion: ((Bool) -> Void) = { (Bool) -> Void in
            self.isHidden = true
        }
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
}
