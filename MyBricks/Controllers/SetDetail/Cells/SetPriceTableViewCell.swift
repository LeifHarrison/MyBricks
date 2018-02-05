//
//  SetPriceTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/5/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetPriceTableViewCell: UITableViewCell {

    //@IBOutlet weak var priceTitleLabel: UILabel!
    //@IBOutlet weak var priceLabel: UILabel!
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.text = NSLocalizedString("Retail Price", comment: "")
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        detailTextLabel?.text = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        detailTextLabel?.text = set.preferredPriceString
    }
    
}
