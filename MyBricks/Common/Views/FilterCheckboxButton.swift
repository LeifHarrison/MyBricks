//
//  FilterCheckboxButton.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/15/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

@IBDesignable
class FilterCheckboxButton: UIButton {
    
    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    public init(title: String) {
        super.init(frame: CGRect.zero)
        commitInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commitInit()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func commitInit() {
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        setTitleColor(UIColor.slateBlue, for: .normal)
        setImage(#imageLiteral(resourceName: "checkboxEmpty"), for: .normal)
        
        setTitleColor(UIColor.lightNavy, for: .selected)
        setImage(#imageLiteral(resourceName: "checkboxFull"), for: .selected)
    }

}
