//
//  UIResponder+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/14/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

private var firstResponderRef: UIResponder?

extension UIResponder {
    
    static var firstResponder: UIResponder? {
        firstResponderRef = nil
        // The trick here is, that the selector will be invoked on the first responder
        UIApplication.shared.sendAction(#selector(setFirstResponderRef), to: nil, from: nil, for: nil)
        return firstResponderRef
    }
    
    @objc private func setFirstResponderRef() {
        firstResponderRef = self
    }
    
}
