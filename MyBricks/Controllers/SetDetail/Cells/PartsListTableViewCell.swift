//
//  PartsListTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class PartsListTableViewCell: BorderedGradientTableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var imageBorderView: UIView!
    @IBOutlet weak var partImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var partNumberLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityView: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageBorderView.applyBorderShadowStyle()
        quantityView.applyRoundedShadowStyle()
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        partImageView.image = nil
        nameLabel.text = ""
        colorLabel.text = ""
        partNumberLabel.text = ""
        quantityLabel.text = ""
        quantityLabel.isHidden = false
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with element: Element) {
        nameLabel.text = element.part?.name
        colorLabel.text = element.color?.name
        partNumberLabel.text = element.part?.partNumber?.capitalized
        if let quantity = element.quantity {
            quantityLabel.text = "\(quantity)"
        }
        else {
            quantityLabel.isHidden = true
        }
    }
    
}
