//
//  BricksetCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/8/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class BricksetCollectionTableViewCell: BorderedGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var ownedSetsLabel: UILabel!
    @IBOutlet weak var wantedSetsLabel: UILabel!
    @IBOutlet weak var ownedMinifigsLabel: UILabel!
    @IBOutlet weak var wantedMinifigsLabel: UILabel!

    @IBOutlet weak var activityContainerView: UIView!
    @IBOutlet weak var activityIndicatorView: ActivityIndicatorView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        activityIndicatorView.style = .small
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ownedSetsLabel.text = nil
        wantedSetsLabel.text = nil
        ownedMinifigsLabel.text = nil
        wantedMinifigsLabel.text = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithCollectionTotals(_ collectionTotals: UserCollectionTotals?) {
        if let totals = collectionTotals {
            activityIndicatorView.stopAnimating()
            activityContainerView.isHidden = true
            ownedSetsLabel.attributedText = totals.setsOwnedAttributedDescription()
            wantedSetsLabel.attributedText = totals.setsWantedAttributedDescription()
            ownedMinifigsLabel.attributedText = totals.minifigsOwnedAttributedDescription()
            wantedMinifigsLabel.attributedText = totals.minifigsWantedAttributedDescription()
        }
        else {
            activityContainerView.isHidden = false
            activityIndicatorView.startAnimating()
        }
    }
}

//==============================================================================
// MARK: - UserCollectionTotals extensions
//==============================================================================

extension UserCollectionTotals {
    
    static let regularAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.black]
    static let boldAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.black]
    
    func setsOwnedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You own ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalSetsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" sets, ", attributes:UserCollectionTotals.regularAttributes))
        attributedDescription.append(NSAttributedString(string:"\(totalDistinctSetsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" different", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }
    
    func setsWantedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You want ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalSetsWanted ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" sets", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }
    
    func minifigsOwnedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You own ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" minifigs", attributes:UserCollectionTotals.regularAttributes))
        // Add back in once the Brickset API supports totalDistinctMinifigsOwned
        //attributedDescription.append(NSAttributedString(string:" minifigs, ", attributes:UserCollectionTotals.regularAttributes))
        //attributedDescription.append(NSAttributedString(string:"\(totalDistinctMinifigsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        //attributedDescription.append(NSAttributedString(string:" different", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }
    
    func minifigsWantedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You want ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsWanted ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" minifigs", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

}
