//
//  SetDetailTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var setNumberField: UILabel!
    @IBOutlet weak var setNameField: UILabel!
    @IBOutlet weak var themeGroupField: UILabel!
    @IBOutlet weak var themeField: UILabel!
    @IBOutlet weak var subthemeField: UILabel!
    @IBOutlet weak var availabilityField: UILabel!
    @IBOutlet weak var retailPriceLabel: UILabel!
    @IBOutlet weak var retiredView: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setNumberField.text = ""
        setNameField.text = ""
        themeGroupField.text = "0"
        themeField.text = "0"
        availabilityField.text = "0"
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        setNameField.text = set.name
        setNumberField.text = set.fullSetNumber
        themeField.text = set.themeDetail()
        themeGroupField.text = set.themeGroup?.capitalized
        availabilityField.text = set.availabilityDetail()

        var retailPrice = ""
        for price in set.retailPrices {
            let flag = price.locale.emojiFlag ?? "🇺🇸"
            let currencySymbol = price.locale.currencySymbol ?? "$"
            retailPrice += (flag + " " + currencySymbol + price.price)
        }
        retailPriceLabel.text = set.preferredPriceString

        // Future additions, hopefully...
        //ageRangeField.text = "-"
        //setTypeField.text = "-"
        //tagsField.text = "-"
    }

}
