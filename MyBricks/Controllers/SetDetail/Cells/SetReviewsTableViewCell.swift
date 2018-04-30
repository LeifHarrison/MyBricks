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
    @IBOutlet weak var ratingLabel: UILabel!
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
        ratingView.settings.filledColor = UIColor.lightNavy
        ratingView.settings.emptyColor = UIColor.white
        ratingView.settings.emptyBorderColor = UIColor.slateBlue
        ratingView.settings.filledBorderColor = UIColor.slateBlue
        ratingView.settings.textColor = UIColor.lightNavy
        ratingView.settings.textFont = UIFont.systemFont(ofSize: 16, weight: .semibold)

        titleLabel.text = "Rating"
        
        addBorder()
        addGradientBackground()

        accessoryView = UIImageView(image: UIImage(named:"forward"))
        accessoryView?.tintColor = UIColor.lightNavy

        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        ratingView.rating = 0
        reviewCountLabel.text = nil
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populate(with set: Set) -> Void {
        if let rating = set.rating {
            let ratingDouble = NSDecimalNumber(decimal:rating).doubleValue
            ratingView.rating = ratingDouble
            ratingLabel.text = String(format:"%0.1f", ratingDouble)
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

