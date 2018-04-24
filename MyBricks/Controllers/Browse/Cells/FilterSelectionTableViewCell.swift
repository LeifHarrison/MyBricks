//
//  FilterSelectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/24/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class FilterSelectionTableViewCell: UITableViewCell {

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tintColor = UIColor.lightNavy
        textLabel?.backgroundColor = UIColor.white
        textLabel?.textColor = UIColor.lightNavy
        detailTextLabel?.backgroundColor = UIColor.white
        detailTextLabel?.textColor = UIColor.slateBlue
        
        addBorder()
        addGradientBackground()
    }
    
}
