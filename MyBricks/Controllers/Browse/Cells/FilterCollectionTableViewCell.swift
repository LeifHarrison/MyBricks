//
//  FilterCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/13/18.
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

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func toggleFilterOwned(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toggleFilterOwned?(sender.isSelected)
    }
    
    @IBAction func toggleFilterNotOwned(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toggleFilterNotOwned?(sender.isSelected)
    }
    
    @IBAction func toggleFilterWanted(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toggleFilterWanted?(sender.isSelected)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with filterOptions: FilterOptions) -> Void {
        ownedCheckboxButton.isSelected = filterOptions.filterOwned
        notOwnedCheckboxButton.isSelected = filterOptions.filterNotOwned
        wantedCheckboxButton.isSelected = filterOptions.filterWanted
    }
    
}
