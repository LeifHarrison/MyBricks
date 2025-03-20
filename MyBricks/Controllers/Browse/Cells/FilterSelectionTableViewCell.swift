//
//  FilterSelectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/24/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class FilterSelectionTableViewCell: BorderedGradientTableViewCell {

    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tintColor = UIColor.lightNavy
        textLabel?.backgroundColor = UIColor.clear
        textLabel?.textColor = UIColor.lightNavy
        detailTextLabel?.backgroundColor = UIColor.clear
        detailTextLabel?.textColor = UIColor.slateBlue
    }
    
}
