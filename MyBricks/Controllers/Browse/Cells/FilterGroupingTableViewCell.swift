//
//  FilterGroupingTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/13/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class FilterGroupingTableViewCell: UITableViewCell, ReusableView {

    @IBOutlet weak var groupThemeRadioButton: UIButton!
    @IBOutlet weak var groupSubthemeRadioButton: UIButton!
    @IBOutlet weak var groupYearRadioButton: UIButton!

    var groupingTypeSelected: ((GroupingType) -> Void)? = nil
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func selectGroupByTheme(_ sender: UIButton) {
        groupThemeRadioButton.isSelected = true
        groupSubthemeRadioButton.isSelected = false
        groupYearRadioButton.isSelected = false
        groupingTypeSelected?(.theme)
    }
    
    @IBAction func selectGroupBySubtheme(_ sender: UIButton) {
        groupThemeRadioButton.isSelected = false
        groupSubthemeRadioButton.isSelected = true
        groupYearRadioButton.isSelected = false
        groupingTypeSelected?(.subtheme)
    }
    
    @IBAction func selectGroupByYear(_ sender: UIButton) {
        groupThemeRadioButton.isSelected = false
        groupSubthemeRadioButton.isSelected = false
        groupYearRadioButton.isSelected = true
        groupingTypeSelected?(.year)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with filterOptions: FilterOptions) -> Void {
        groupThemeRadioButton.isSelected = (filterOptions.grouping == .theme)
        groupSubthemeRadioButton.isSelected = (filterOptions.grouping == .subtheme)
        groupYearRadioButton.isSelected = (filterOptions.grouping == .year)
    }
    
}
