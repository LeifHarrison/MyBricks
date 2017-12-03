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
    
}
