//
//  SetReviewsTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

class SetReviewsTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    
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
        ratingView.settings.textColor = UIColor.black
        ratingView.settings.textFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

        titleLabel.text = "Rating"
        
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        ratingView.rating = 0
        ratingView.text = "N/A"
        reviewCountLabel.text = nil
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populate(with set: Set) -> Void {
        if let rating = set.rating {
            let ratingDouble = NSDecimalNumber(decimal:rating).doubleValue
            ratingView.rating = ratingDouble
            ratingView.text = String(format:"%0.2g", ratingDouble)
        }
        if let reviewCount = set.reviewCount, reviewCount > 0 {
            reviewCountLabel.attributedText = attributedReviewCountDescription(for: set)
        }
        else {
            reviewCountLabel.text = "No Reviews Yet"
        }
    }
    
    func attributedReviewCountDescription(for set: Set) -> NSAttributedString {
        let textColor = reviewCountLabel.textColor ?? UIColor.black
        let regularAttributes: [NSAttributedStringKey : Any] = [.font: reviewCountLabel.font, .foregroundColor: textColor]
        let boldAttributes: [NSAttributedStringKey : Any] = [.font: reviewCountLabel.font.bold(), .foregroundColor: textColor]

        let attributedDescription = NSMutableAttributedString(string:"(from ", attributes:regularAttributes)
        if let reviewCount = set.reviewCount, reviewCount > 0 {
            attributedDescription.append(NSAttributedString(string:"\(reviewCount)", attributes:boldAttributes))
        }
        attributedDescription.append(NSAttributedString(string:" reviews)", attributes:regularAttributes))
        return attributedDescription
    }

}

