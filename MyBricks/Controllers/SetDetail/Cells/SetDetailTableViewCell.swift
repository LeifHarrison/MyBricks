//
//  SetDetailTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var setNumberField: UILabel!
    @IBOutlet weak var setYearField: UILabel!
    @IBOutlet weak var setNameField: UILabel!
    @IBOutlet weak var themeGroupField: UILabel!
    @IBOutlet weak var themeField: UILabel!
    @IBOutlet weak var availabilityField: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        addBorder()
        addGradientBackground()
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setNumberField.text = ""
        setYearField.text = ""
        setNameField.text = ""
        themeGroupField.text = "0"
        themeField.text = "0"
        availabilityField.text = "0"
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        setNumberField.text = set.fullSetNumber
        setYearField.text = set.year
        setNameField.text = set.name
        themeField.text = set.themeDescription()
        themeGroupField.text = set.themeGroup?.capitalized
        availabilityField.text = set.availabilityDescription()
    }

}
