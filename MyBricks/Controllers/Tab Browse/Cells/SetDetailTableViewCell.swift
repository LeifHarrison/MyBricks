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

    @IBOutlet weak var setImageView: UIImageView!
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
    @IBOutlet weak var retailPriceLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!

    @IBOutlet weak var ownedView: UIView!
    @IBOutlet weak var wantedView: UIView!
    @IBOutlet weak var retiredView: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        ratingView.settings.starSize = 18.0
        ratingView.settings.fillMode = .precise
        ratingView.settings.starMargin = 4.0
        ratingView.settings.updateOnTouch = false
        ratingView.settings.filledColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        ratingView.settings.emptyColor = UIColor.white
        ratingView.settings.emptyBorderColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        ratingView.settings.filledBorderColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        ratingView.settings.textColor = UIColor(white: 0.2, alpha: 1.0)
        ratingView.settings.textFont = UIFont.systemFont(ofSize: 14)
        
        retiredView.layer.cornerRadius = retiredView.bounds.height / 2
        ownedView.layer.cornerRadius = ownedView.bounds.height / 2
        wantedView.layer.cornerRadius = ownedView.bounds.height / 2
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setNumberField.text = ""
        setNameField.text = ""
        //setTypeField.text = ""
        themeGroupField.text = "0"
        themeField.text = "0"
        yearReleasedField.text = "0"
        //tagsField.text = "0"
        piecesField.text = "0"
        minifiguresField.text = "0"
        ageRangeField.text = "0"
        //packagingField.text = "0"
        //weightField.text = "0"
        availabilityField.text = "0"
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(set : Set) -> Void {
        setNumberField.text = set.number
        yearReleasedField.text = set.year
        piecesField.text = "\(set.pieces ?? 0)"
        minifiguresField.text = "\(set.minifigs ?? 0)"
        ratingView.rating = set.rating ?? 0
        ratingView.text = "(\(set.reviewCount ?? 0))"
        setNameField.text = set.name
        themeField.text = set.themeDetail()
        themeGroupField.text = set.themeGroup
        availabilityField.text = set.availabilityDetail()
        retailPriceLabel.text = "🇺🇸 $\(set.retailPriceUS ?? "-") | 🇨🇦 $\(set.retailPriceCA ?? "-") | 🇬🇧 £\(set.retailPriceUK ?? "-") | 🇪🇺 €\(set.retailPriceEU ?? "-")"

        // Future additions, hopefully...
        //ageRangeField.text = "-"
        //setTypeField.text = "-"
        //tagsField.text = "-"

        // Set Image View populated by the View Controller
    }

}
