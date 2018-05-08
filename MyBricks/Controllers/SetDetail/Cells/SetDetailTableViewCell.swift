//
//  SetDetailTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var setNameField: UILabel!
    @IBOutlet weak var setNumberField: UILabel!
    @IBOutlet weak var ageRangeField: UILabel!
    @IBOutlet weak var setYearField: UILabel!
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
        setNameField.text = ""
        setNumberField.text = ""
        ageRangeField.text = ""
        setYearField.text = ""
        themeField.text = "0"
        themeGroupField.text = "0"
        availabilityField.text = "0"
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        setNameField.text = set.name
        setNumberField.text = set.fullSetNumber
        ageRangeField.text = set.ageRangeString
        setYearField.text = set.year
        themeField.text = set.themeDescription()
        themeGroupField.text = set.categoryAndGroupDescription()
        availabilityField.text = set.availabilityDescription()
    }

}
