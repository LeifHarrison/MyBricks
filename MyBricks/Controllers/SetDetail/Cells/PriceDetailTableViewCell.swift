//
//  PriceDetailTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 3/1/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class PriceDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pricePerPieceLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        addBorder()
        addGradientBackground()

        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        regionLabel.text = ""
        priceLabel.text = ""
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with retailPrice: SetRetailPrice) {
        regionLabel.text = retailPrice.locale.localizedString(forRegionCode: retailPrice.locale.regionCode!)
        priceLabel.text = retailPrice.priceDescription()
        pricePerPieceLabel.text = retailPrice.pricePerPieceDescription()
    }
    
}
