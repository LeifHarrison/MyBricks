//
//  SetReviewsTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

class SetReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()

        ratingView.settings.starSize = 22.0
        ratingView.settings.fillMode = .precise
        ratingView.settings.starMargin = 2.0
        ratingView.settings.updateOnTouch = false
        ratingView.settings.filledColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        ratingView.settings.emptyColor = UIColor.white
        ratingView.settings.emptyBorderColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        ratingView.settings.filledBorderColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        ratingView.settings.textColor = UIColor(white: 0.2, alpha: 1.0)
        ratingView.settings.textFont = UIFont.systemFont(ofSize: 14)

        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        ratingView.rating = 0
        ratingView.text = nil
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithSet(_ set : Set) -> Void {
        titleLabel.text = "Reviews (\(set.reviewCount ?? 0))"
        if let rating = set.rating {
            ratingView.rating = NSDecimalNumber(decimal:rating).doubleValue
        }
    }

}
