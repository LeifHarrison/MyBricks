//
//  SetDetailContainerView.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/2/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }

    private func commitInit() {
        addGradientBackground()
        
        layer.cornerRadius = 3.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
}
