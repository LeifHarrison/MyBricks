//
//  SetCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/26/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

class SetCollectionTableViewCell: BlueGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var ownedStatusView: UIView!
    @IBOutlet weak var ownedStatusLabel: UILabel!
    @IBOutlet weak var wantedStatusView: UIView!
    @IBOutlet weak var wantedStatusLabel: UILabel!
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var ratingIndicator: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var notesIndicator: UIImageView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryView = UIImageView(image: UIImage(named:"disclosure"))
        accessoryView?.tintColor = UIColor.lightNavy
        
        ownedStatusView.applyLightBlackShadowStyle()
        wantedStatusView.applyLightBlackShadowStyle()

        prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ownedStatusView.layer.cornerRadius = ownedStatusView.frame.height / 2
        wantedStatusView.layer.cornerRadius = wantedStatusView.frame.height / 2
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        
        ownedStatusView.isHidden = true
        wantedStatusView.isHidden = true
        ratingContainerView.isHidden = true
        notesIndicator.isHidden = true
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with set: SetDetail) {
        ownedStatusView.isHidden = !set.isOwned
        wantedStatusView.isHidden = !set.isWanted

        if set.isOwned {
            ownedStatusLabel.text = "\(set.collection?.qtyOwned ?? 0)"
            ownedStatusView.backgroundColor = UIColor.bricksetOwned
        }
        else if set.isWanted {
            wantedStatusLabel.text = "W"
            wantedStatusView.backgroundColor = UIColor.bricksetWanted
        }

        if let rating = set.collection?.rating, rating > 0 {
            ratingContainerView.isHidden = false
            ratingLabel.text = "\(rating)"
        }

        if let notes = set.collection?.notes, notes.count > 0 {
            notesIndicator.isHidden = false
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
}
