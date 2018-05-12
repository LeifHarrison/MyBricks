//
//  SetListTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetListTableViewCell: BorderedGradientTableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var imageBorderView: UIView!
    @IBOutlet weak var setImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var subthemeLabel: UILabel!
    @IBOutlet weak var partsContainerView: UIView!
    @IBOutlet weak var piecesLabel: UILabel!
    @IBOutlet weak var minifigsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var collectionStatusView: UIView!
    @IBOutlet weak var collectionStatusLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()

        imageBorderView.applyBorderShadowStyle()

        collectionStatusView.layer.shadowColor = UIColor.black.cgColor
        collectionStatusView.layer.shadowOffset =  CGSize(width: 1, height: 1)
        collectionStatusView.layer.shadowOpacity = 0.4
        collectionStatusView.layer.shadowRadius = 2

        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        setNumberLabel.text = ""
        subthemeLabel.text = ""
        piecesLabel.text = ""
        minifigsLabel.text = ""
        priceLabel.text = ""

        collectionStatusView.isHidden = true

        setImageView.af_cancelImageRequest()
        setImageView.layer.removeAllAnimations()
        setImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionStatusView.layer.cornerRadius = collectionStatusView.frame.height / 2
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populate(with set: Set, options: FilterOptions) {
        
        nameLabel.text = set.name
        setNumberLabel.text = set.displayableSetNumber
        
        if let grouping = options.grouping, grouping == .subtheme {
            subthemeLabel.text = set.year
        }
        else {
            subthemeLabel.text = set.subtheme
        }
        
        piecesLabel.text = "\(set.pieces ?? 0)"
        minifigsLabel.text = "\(set.minifigs ?? 0)"
        priceLabel.text = set.preferredPriceString

        collectionStatusView.isHidden = !set.owned && !set.wanted
        if set.owned {
            collectionStatusLabel.text = "\(set.quantityOwned ?? 0)"
            collectionStatusView.backgroundColor = UIColor.bricksetOwned
        }
        else if set.wanted {
            collectionStatusLabel.text = "W"
            collectionStatusView.backgroundColor = UIColor.bricksetWanted
        }
        
        let urlString = (UIScreen.main.scale > 1.5) ? set.largeThumbnailURL : set.thumbnailURL
        if let urlString = urlString, let url = URL(string: urlString) {
            setImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
        }

    }

}
