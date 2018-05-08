//
//  FilterUnreleasedTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/7/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class FilterUnreleasedTableViewCell: UITableViewCell, ReusableView {

    @IBOutlet weak var showUnreleasedButton: UIButton!

    var toggleFilterShowUnreleased: ((Bool) -> Void)? = nil
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        tintColor = UIColor.lightNavy
        
        showUnreleasedButton.applyCheckboxStyle()
        
        addBorder()
        addGradientBackground()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func toggleShowUnreleased(_ sender: UIButton) {
        showUnreleasedButton.isSelected = !showUnreleasedButton.isSelected
        toggleFilterShowUnreleased?(showUnreleasedButton.isSelected)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with filterOptions: FilterOptions) -> Void {
        showUnreleasedButton.isSelected = filterOptions.showUnreleased
    }
    
}
