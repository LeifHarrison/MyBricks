//
//  SetPriceTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/5/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetPriceTableViewCell: BlueGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryView = UIImageView(image: UIImage(named:"forward"))
        accessoryView?.tintColor = UIColor.lightNavy
        
        priceTitleLabel.text = NSLocalizedString("Retail Price", comment: "")
        
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        priceLabel.text = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with set: Set) {
        priceLabel.text = set.preferredPriceDescription
    }
    
}
