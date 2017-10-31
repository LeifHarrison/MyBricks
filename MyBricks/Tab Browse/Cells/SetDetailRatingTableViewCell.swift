//
//  SetDetailRatingTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/30/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import Cosmos

class SetDetailRatingTableViewCell: UITableViewCell {

    @IBOutlet weak var setRatingView: CosmosView!
    @IBOutlet weak var reviewsField: UILabel!
    @IBOutlet weak var yourRatingView: CosmosView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()

        setRatingView.settings.starSize = 18.0
        setRatingView.settings.fillMode = .precise
        setRatingView.settings.starMargin = 4.0
        setRatingView.settings.updateOnTouch = false
        setRatingView.settings.filledColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        setRatingView.settings.emptyBorderColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        setRatingView.settings.filledBorderColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        setRatingView.settings.textColor = UIColor.white
        setRatingView.settings.textFont = UIFont.systemFont(ofSize: 14)

        yourRatingView.settings.starSize = 25.0
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setRatingView.rating = 0.0
        setRatingView.text = ""
        yourRatingView.rating = 0.0
        yourRatingView.text = ""
        reviewsField.text = "0"
    }

}
