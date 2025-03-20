//
//  SetReviewsTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

class SetReviewsTableViewCell: BlueGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "Rating"
        setupRatingView()

        accessoryView = UIImageView(image: UIImage(named: "disclosure"))
        accessoryView?.tintColor = UIColor.lightNavy
        
        prepareForReuse()
    }

    // -------------------------------------------------------------------------
    // MARK: - Reuse
    // -------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        ratingView.rating = 0
    }

    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------

    func populate(with set: SetDetail) {
        if let rating = set.rating {
            let ratingDouble = NSDecimalNumber(decimal: rating).doubleValue
            ratingView.rating = ratingDouble
            ratingLabel.text = String(format: "%0.1f", ratingDouble)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------
    
    private func setupRatingView() {
        ratingView.settings.starSize = 22.0
        ratingView.settings.fillMode = .precise
        ratingView.settings.starMargin = 2.0
        ratingView.settings.textColor = UIColor.lightNavy
        ratingView.settings.textFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        ratingView.settings.updateOnTouch = false
    }
}
