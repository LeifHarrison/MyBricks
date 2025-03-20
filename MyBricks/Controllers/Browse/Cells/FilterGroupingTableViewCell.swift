//
//  FilterGroupingTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/13/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class FilterGroupingTableViewCell: BorderedGradientTableViewCell, ReusableView {

    @IBOutlet weak var groupThemeRadioButton: UIButton!
    @IBOutlet weak var groupSubthemeRadioButton: UIButton!
    @IBOutlet weak var groupYearRadioButton: UIButton!

    var groupingTypeSelected: ((GroupingType?) -> Void)?
    
    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        groupThemeRadioButton.applyCheckboxStyle()
        groupSubthemeRadioButton.applyCheckboxStyle()
        groupYearRadioButton.applyCheckboxStyle()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------
    
    @IBAction func selectGroupByTheme(_ sender: UIButton) {
        groupThemeRadioButton.isSelected = !groupThemeRadioButton.isSelected
        groupSubthemeRadioButton.isSelected = false
        groupYearRadioButton.isSelected = false
        groupingTypeSelected?(groupThemeRadioButton.isSelected ? .theme : nil)
    }
    
    @IBAction func selectGroupBySubtheme(_ sender: UIButton) {
        groupThemeRadioButton.isSelected = false
        groupSubthemeRadioButton.isSelected = !groupSubthemeRadioButton.isSelected
        groupYearRadioButton.isSelected = false
        groupingTypeSelected?(groupSubthemeRadioButton.isSelected ? .subtheme : nil)
    }
    
    @IBAction func selectGroupByYear(_ sender: UIButton) {
        groupThemeRadioButton.isSelected = false
        groupSubthemeRadioButton.isSelected = false
        groupYearRadioButton.isSelected = !groupYearRadioButton.isSelected
        groupingTypeSelected?(groupYearRadioButton.isSelected ? .year : nil)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------
    
    func populate(with filterOptions: FilterOptions) {
        if filterOptions.selectedTheme != nil {
            groupThemeRadioButton.isEnabled = false
        }
        else {
            groupThemeRadioButton.isEnabled = true
            groupThemeRadioButton.isSelected = (filterOptions.grouping == .theme)
        }
        groupSubthemeRadioButton.isSelected = (filterOptions.grouping == .subtheme)
        groupYearRadioButton.isSelected = (filterOptions.grouping == .year)
    }
    
}
