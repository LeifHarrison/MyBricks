//
//  PriceDetailTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 3/1/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class PriceDetailTableViewCell: BorderedGradientTableViewCell {

    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pricePerPieceLabel: UILabel!

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
        regionLabel.text = ""
        priceLabel.text = ""
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with retailPrice: SetRetailPrice) {
        let regionCode = retailPrice.locale.region?.identifier ?? "US"
        regionLabel.text = retailPrice.locale.localizedString(forRegionCode: regionCode)
        priceLabel.text = retailPrice.priceDescription()
        pricePerPieceLabel.text = retailPrice.pricePerPieceDescription()
    }
    
}
