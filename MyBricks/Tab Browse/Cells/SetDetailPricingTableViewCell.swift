//
//  SetDetailPricingTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/30/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SetDetailPricingTableViewCell: UITableViewCell {

    @IBOutlet weak var retailPriceField: UILabel!
    @IBOutlet weak var currentValueField: UILabel!
    @IBOutlet weak var pricePerPieceField: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        retailPriceField.text = "-"
        currentValueField.text = "-"
        pricePerPieceField.text = "-"
    }

}
