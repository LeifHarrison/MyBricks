//
//  UIButton+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/21/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

extension UIButton {
    
    func applyDefaultStyle() {
        self.backgroundColor = UIColor(named: "bricksetBlue")
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.layer.cornerRadius = 5.0
    }
    
}
