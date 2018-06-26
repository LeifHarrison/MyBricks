//
//  LightGradientButton.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/19/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

@IBDesignable
class LightGradientButton: UIButton {
    
    let gradientView = GradientView()
    let highlightOverlay = UIView()

    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
//    public convenience init(type buttonType: UIButtonType){
//        super.init(type: buttonType)
//        commitInit()
//    }

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commitInit()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Superclass Overrides
    //--------------------------------------------------------------------------
    
    override var isHighlighted: Bool {
        didSet {
            highlightOverlay.isHidden = !isHighlighted
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    func commitInit() {
        clipsToBounds = false
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.15

        addGradient()
        addHighlightOverlay()
    }
    
    func addGradient() {
        gradientView.isUserInteractionEnabled = false
        gradientView.frame = self.bounds
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.startColor = UIColor.white
        gradientView.endColor = UIColor.whiteTwo
        insertSubview(gradientView, at: 0)
        gradientView.constrainToSuperview()
    }
    
    func addHighlightOverlay() {
        highlightOverlay.isUserInteractionEnabled = false
        highlightOverlay.backgroundColor = UIColor.lightNavy.withAlphaComponent(0.1)
        highlightOverlay.frame = self.bounds
        highlightOverlay.translatesAutoresizingMaskIntoConstraints = false
        highlightOverlay.isHidden = true
        insertSubview(highlightOverlay, aboveSubview: gradientView)
        highlightOverlay.constrainToSuperview()
    }

}
