//
//  SetDetailTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailTableViewCell: BorderedGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var setNameField: UILabel!
    @IBOutlet weak var setNumberField: UILabel!
    @IBOutlet weak var themeGroupField: UILabel!
    @IBOutlet weak var themeField: UILabel!
    @IBOutlet weak var availabilityField: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setNameField.text = ""
        setNumberField.text = ""
        themeField.text = "0"
        themeGroupField.text = "0"
        availabilityField.text = "0"
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with set: Set) {
        setNameField.text = set.name
        setNumberField.text = set.setNumberAgeYearDescription
        themeField.text = set.themeDescription()
        themeGroupField.text = set.categoryAndGroupDescription()
        availabilityField.text = set.availabilityDescription()
    }

}
