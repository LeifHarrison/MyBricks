//
//  SetCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/26/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

class SetCollectionTableViewCell: BorderedGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var collectionStatusView: UIView!
    @IBOutlet weak var collectionStatusLabel: UILabel!
    @IBOutlet weak var ratingIndicator: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var notesIndicator: UIImageView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryView = UIImageView(image: UIImage(named:"forward"))
        accessoryView?.tintColor = UIColor.lightNavy
        
        collectionStatusView.layer.shadowColor = UIColor.black.cgColor
        collectionStatusView.layer.shadowOffset =  CGSize(width: 1, height: 1)
        collectionStatusView.layer.shadowOpacity = 0.4
        collectionStatusView.layer.shadowRadius = 2

        prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionStatusView.layer.cornerRadius = collectionStatusView.frame.height / 2
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with set: Set) {
        collectionStatusView.isHidden = !set.owned && !set.wanted
        if set.owned {
            collectionStatusLabel.text = "\(set.quantityOwned ?? 0)"
            collectionStatusView.backgroundColor = UIColor.bricksetOwned
        }
        else if set.wanted {
            collectionStatusLabel.text = "W"
            collectionStatusView.backgroundColor = UIColor.bricksetWanted
        }

    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
}
