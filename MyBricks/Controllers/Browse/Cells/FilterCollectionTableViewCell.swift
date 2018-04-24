//
//  FilterCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/13/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class FilterCollectionTableViewCell: UITableViewCell, ReusableView {

    @IBOutlet weak var ownedCheckboxButton: UIButton!
    @IBOutlet weak var notOwnedCheckboxButton: UIButton!
    @IBOutlet weak var wantedCheckboxButton: UIButton!

    var toggleFilterOwned: ((Bool) -> Void)? = nil
    var toggleFilterNotOwned: ((Bool) -> Void)? = nil
    var toggleFilterWanted: ((Bool) -> Void)? = nil

    private var exclusiveSelection = false
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tintColor = UIColor.lightNavy
        ownedCheckboxButton.applyCheckboxStyle()
        notOwnedCheckboxButton.applyCheckboxStyle()
        wantedCheckboxButton.applyCheckboxStyle()

        addBorder()
        addGradientBackground()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func toggleFilterOwned(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toggleFilterOwned?(sender.isSelected)
        if exclusiveSelection && sender.isSelected {
            wantedCheckboxButton.isSelected = false
            toggleFilterWanted?(false)
        }
    }
    
    @IBAction func toggleFilterNotOwned(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toggleFilterNotOwned?(sender.isSelected)
    }
    
    @IBAction func toggleFilterWanted(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toggleFilterWanted?(sender.isSelected)
        if exclusiveSelection && sender.isSelected {
            ownedCheckboxButton.isSelected = false
            toggleFilterOwned?(false)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with filterOptions: FilterOptions) -> Void {
        ownedCheckboxButton.isSelected = filterOptions.filterOwned
        wantedCheckboxButton.isSelected = filterOptions.filterWanted
        
        exclusiveSelection = filterOptions.showingUserSets
        if filterOptions.showingUserSets {
            notOwnedCheckboxButton.isEnabled = false
            notOwnedCheckboxButton.isSelected = false
        }
        else {
            notOwnedCheckboxButton.isSelected = filterOptions.filterNotOwned
        }
    }
    
}
