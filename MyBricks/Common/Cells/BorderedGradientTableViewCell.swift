//
//  BorderedGradientTableViewCell.swift
//  MyBricks
//
//  Created by Leif on 5/12/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class BorderedGradientTableViewCell: UITableViewCell {

    let gradientView = GradientView()
    let highlightOverlay = UIView()
    
    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBorder()
        addGradient()
        addHighlightOverlay()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Superclass Overrides
    // -------------------------------------------------------------------------
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if selectionStyle != .none {
            highlightOverlay.isHidden = !highlighted
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------
    
    func addGradient() {
        gradientView.frame = self.bounds
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.startColor = UIColor.white
        gradientView.endColor = UIColor.whiteTwo
        insertSubview(gradientView, at: 0)
        gradientView.constrainToSuperview()
    }

    func addHighlightOverlay() {
        highlightOverlay.backgroundColor = UIColor.lightNavy.withAlphaComponent(0.1)
        highlightOverlay.frame = self.bounds
        highlightOverlay.translatesAutoresizingMaskIntoConstraints = false
        highlightOverlay.isHidden = true
        insertSubview(highlightOverlay, aboveSubview: gradientView)
        highlightOverlay.constrainToSuperview()
    }
    
}
