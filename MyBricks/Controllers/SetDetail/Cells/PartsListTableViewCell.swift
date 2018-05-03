//
//  PartsListTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class PartsListTableViewCell: UITableViewCell, NibLoadableView, ReusableView {

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
        
        addBorder()
        addGradientBackground()

        imageBorderView.layer.borderColor = UIColor.whiteThree.cgColor
        imageBorderView.layer.borderWidth = 1.0 / UIScreen.main.scale
        imageBorderView.layer.cornerRadius = 3
        imageBorderView.layer.shadowColor = UIColor.blueGrey.cgColor
        imageBorderView.layer.shadowOffset =  CGSize(width: 1, height: 1)
        imageBorderView.layer.shadowOpacity = 0.4
        imageBorderView.layer.shadowRadius = 2

        quantityView.layer.cornerRadius = quantityView.bounds.height / 2

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
    
    func populateWithElement(_ element : Element) -> Void {
        nameLabel.text = element.part?.name
        colorLabel.text = element.color?.name
        partNumberLabel.text = element.part?.partNumber?.capitalized
        if let quantity = element.quantity {
            quantityLabel.text = "×\(quantity)"
        }
        else {
            quantityLabel.isHidden = true
        }
    }
    
}
