//
//  BlueGradientTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/30/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class BlueGradientTableViewCell: UITableViewCell {

    let highlightOverlay = UIView()
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBorder()
        addGradientBackground(withColors: [UIColor.almostWhite, UIColor.paleGrey])
        addHighlightOverlay()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Superclass Overrides
    //--------------------------------------------------------------------------
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if selectionStyle != .none {
            highlightOverlay.isHidden = !highlighted
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    func addHighlightOverlay() {
        highlightOverlay.backgroundColor = UIColor.lightNavy.withAlphaComponent(0.1)
        highlightOverlay.frame = self.bounds
        highlightOverlay.translatesAutoresizingMaskIntoConstraints = false
        highlightOverlay.isHidden = true
        insertSubview(highlightOverlay, at: 1)
        highlightOverlay.constrainToSuperview()
    }
    
}
