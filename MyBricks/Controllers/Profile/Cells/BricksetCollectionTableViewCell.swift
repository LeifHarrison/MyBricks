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

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
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
    
    func populateWithCollectionTotals(_ collectionTotals: UserCollectionTotals) {
        ownedSetsLabel.attributedText = collectionTotals.setsOwnedAttributedDescription()
        wantedSetsLabel.attributedText = collectionTotals.setsWantedAttributedDescription()
        ownedMinifigsLabel.attributedText = collectionTotals.minifigsOwnedAttributedDescription()
        wantedMinifigsLabel.attributedText = collectionTotals.minifigsWantedAttributedDescription()
    }
}

//==============================================================================
// MARK: - UserCollectionTotals extensions
//==============================================================================

extension UserCollectionTotals {
    
    static let regularAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.black]
    static let boldAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.black]
    
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
        attributedDescription.append(NSAttributedString(string:" minifigs, ", attributes:UserCollectionTotals.regularAttributes))
        attributedDescription.append(NSAttributedString(string:"\(totalDistinctMinifigsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" different", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }
    
    func minifigsWantedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You want ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsWanted ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" minifigs", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

}
