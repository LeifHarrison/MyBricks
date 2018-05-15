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
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBorder()
        addGradient()
        addHighlightOverlay()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if selectionStyle != .none {
            highlightOverlay.isHidden = !highlighted
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    func addGradient() {
        gradientView.frame = self.bounds
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.startColor = UIColor.white
        gradientView.endColor = UIColor.whiteTwo
        insertSubview(gradientView, at: 0)
        
        let top = gradientView.topAnchor.constraint(equalTo: self.topAnchor)
        let bottom = self.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor)
        let leading = gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trailing = self.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
    }

    func addHighlightOverlay() {
        highlightOverlay.backgroundColor = UIColor.lightNavy.withAlphaComponent(0.1)
        highlightOverlay.frame = self.bounds
        highlightOverlay.translatesAutoresizingMaskIntoConstraints = false
        highlightOverlay.isHidden = true
        insertSubview(highlightOverlay, aboveSubview: gradientView)

        let top = highlightOverlay.topAnchor.constraint(equalTo: self.topAnchor)
        let bottom = self.bottomAnchor.constraint(equalTo: highlightOverlay.bottomAnchor)
        let leading = highlightOverlay.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trailing = self.trailingAnchor.constraint(equalTo: highlightOverlay.trailingAnchor)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
    }
    
}
