//
//  FilterSortingDirectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/13/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class FilterSortingDirectionTableViewCell: BorderedGradientTableViewCell, ReusableView {

    @IBOutlet weak var ascendingRadioButton: UIButton!
    @IBOutlet weak var descendingRadioButton: UIButton!

    var sortingDirectionSelected: ((SortingDirection) -> Void)?
    
    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none

        ascendingRadioButton.applyCheckboxStyle()
        descendingRadioButton.applyCheckboxStyle()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------
    
    @IBAction func selectSortAscending(_ sender: UIButton) {
        ascendingRadioButton.isSelected = true
        descendingRadioButton.isSelected = false
        sortingDirectionSelected?(ascendingRadioButton.isSelected ? .ascending : .descending)
    }
    
    @IBAction func selectSortDescending(_ sender: UIButton) {
        ascendingRadioButton.isSelected = false
        descendingRadioButton.isSelected = true
        sortingDirectionSelected?(ascendingRadioButton.isSelected ? .ascending : .descending)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------
    
    func populate(with filterOptions: FilterOptions) {
        ascendingRadioButton.isSelected = (filterOptions.sortingSelection.direction == .ascending)
        descendingRadioButton.isSelected = (filterOptions.sortingSelection.direction == .descending)
    }
    
}
