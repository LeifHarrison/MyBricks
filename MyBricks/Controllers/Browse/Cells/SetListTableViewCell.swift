//
//  SetListTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetListTableViewCell: UITableViewCell {

    static let nibName = "SetListTableViewCell"
    static let reuseIdentifier = "SetListTableViewCell"

    @IBOutlet weak var imageBorderView: UIView!
    @IBOutlet weak var setImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
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

        collectionStatusView.layer.cornerRadius = collectionStatusView.bounds.height / 2
        
        tintColor = UIColor.lightNavy

        addBorder()
        addGradientBackground()

        imageBorderView.layer.borderColor = UIColor.whiteThree.cgColor
        imageBorderView.layer.borderWidth = 1.0 / UIScreen.main.scale
        imageBorderView.layer.cornerRadius = 3
        imageBorderView.layer.shadowColor = UIColor.blueGrey.cgColor
        imageBorderView.layer.shadowRadius = 2
        imageBorderView.layer.shadowOpacity = 0.4
        imageBorderView.layer.shadowOffset =  CGSize(width: 1, height: 1)
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        yearLabel.text = ""
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

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithSet(_ set : Set) -> Void {
        
        nameLabel.text = set.name
        yearLabel.text = set.year
        setNumberLabel.text = set.number
        subthemeLabel.text = set.subtheme
        piecesLabel.text = "\(set.pieces ?? 0)"
        minifigsLabel.text = "\(set.minifigs ?? 0)"
        priceLabel.text = set.preferredPriceString

        collectionStatusView.isHidden = !set.owned && !set.wanted
        if set.owned { collectionStatusLabel.text = "OWNED" }
        else if set.wanted { collectionStatusLabel.text = "WANTED" }
        else { collectionStatusLabel.text = "" }

        let urlString = (UIScreen.main.scale > 1.5) ? set.largeThumbnailURL : set.thumbnailURL
        if let urlString = urlString, let url = URL(string: urlString) {
            setImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
        }

    }

}
