//
//  SetDetailTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import Cosmos

class SetDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var setNumberField: UILabel!
    @IBOutlet weak var setNameField: UILabel!
    @IBOutlet weak var setTypeField: UILabel!
    @IBOutlet weak var themeGroupField: UILabel!
    @IBOutlet weak var themeField: UILabel!
    @IBOutlet weak var subthemeField: UILabel!
    @IBOutlet weak var yearReleasedField: UILabel!
    @IBOutlet weak var tagsField: UILabel!
    @IBOutlet weak var piecesField: UILabel!
    @IBOutlet weak var minifiguresField: UILabel!
    @IBOutlet weak var ageRangeField: UILabel!
    @IBOutlet weak var packagingField: UILabel!
    @IBOutlet weak var weightField: UILabel!
    @IBOutlet weak var availabilityField: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setNumberField.text = ""
        setNameField.text = ""
        setTypeField.text = ""
        themeGroupField.text = "0"
        themeField.text = "0"
        yearReleasedField.text = "0"
        tagsField.text = "0"
        piecesField.text = "0"
        minifiguresField.text = "0"
        ageRangeField.text = "0"
        packagingField.text = "0"
        weightField.text = "0"
        availabilityField.text = "0"
    }

}
