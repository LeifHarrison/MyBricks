//
//  SetPriceTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/5/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetPriceTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    //@IBOutlet weak var priceTitleLabel: UILabel!
    //@IBOutlet weak var priceLabel: UILabel!
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()

        addBorder()
        addGradientBackground()

        accessoryView = UIImageView(image: UIImage(named:"forward"))
        accessoryView?.tintColor = UIColor.lightNavy
        
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
