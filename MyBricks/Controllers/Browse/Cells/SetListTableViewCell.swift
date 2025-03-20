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

    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()

        setImageView.backgroundColor = UIColor.clear
        imageBorderView.applyBorderShadowStyle()

        collectionStatusView.layer.shadowColor = UIColor.black.cgColor
        collectionStatusView.layer.shadowOffset =  CGSize(width: 1, height: 1)
        collectionStatusView.layer.shadowOpacity = 0.4
        collectionStatusView.layer.shadowRadius = 2

        prepareForReuse()
    }

    // -------------------------------------------------------------------------
    // MARK: - Reuse
    // -------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        setNumberLabel.text = ""
        subthemeLabel.text = ""
        piecesLabel.text = ""
        minifigsLabel.text = ""
        priceLabel.text = ""

        collectionStatusView.isHidden = true

        setImageView.af.cancelImageRequest()
        setImageView.layer.removeAllAnimations()
        setImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionStatusView.layer.cornerRadius = collectionStatusView.frame.height / 2
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------

    func populate(with set: SetDetail, options: FilterOptions) {
        
        if let name = set.name, name == "{?}" { // Unreleased set
            nameLabel.text = "Not Yet Released"
        }
        else {
            nameLabel.text = set.name
        }
        setNumberLabel.text = set.displayableSetNumber
        
        if let grouping = options.grouping, grouping == .subtheme {
            if let year = set.year {
                subthemeLabel.text = "\(year)"
            }
            else {
                subthemeLabel.text = "None"
            }
        }
        else {
            subthemeLabel.text = set.subtheme ?? "None"
        }
        
        if set.pieces == nil && set.minifigs == nil {
            partsContainerView.isHidden = true
        }
        else {
            partsContainerView.isHidden = false
            piecesLabel.text = "\(set.pieces ?? 0)"
            minifigsLabel.text = "\(set.minifigs ?? 0)"
        }

        priceLabel.text = set.preferredPriceDescription

        collectionStatusView.isHidden = !set.isOwned && !set.isWanted
        if set.isOwned {
            collectionStatusLabel.text = "\(set.collection?.qtyOwned ?? 0)"
            collectionStatusView.backgroundColor = UIColor.bricksetOwned
        }
        else if set.isWanted {
            collectionStatusLabel.text = "W"
            collectionStatusView.backgroundColor = UIColor.bricksetWanted
        }
        
        setImageView.contentMode = .center
        setImageView.image = #imageLiteral(resourceName: "placeholder1")
        imageBorderView.backgroundColor = UIColor.lightBlueGreyTwo

        if let urlString = set.image?.thumbnailURL, let url = URL(string: urlString) {
            setImageView.af.setImage(withURL: url, imageTransition: .crossDissolve(0.3)) { result in
                if result.value != nil {
                    self.setImageView.contentMode = .scaleAspectFit
                    self.imageBorderView.backgroundColor = UIColor.white
                }
            }
        }

    }

}
