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

    @IBOutlet weak var setImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var subthemeLabel: UILabel!
    @IBOutlet weak var partsContainerView: UIView!
    @IBOutlet weak var piecesLabel: UILabel!
    @IBOutlet weak var minifigsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var ownedView: UIView!
    @IBOutlet weak var wantedView: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()

        ownedView.layer.cornerRadius = ownedView.bounds.height / 2
        wantedView.layer.cornerRadius = ownedView.bounds.height / 2
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

        ownedView.isHidden = true
        wantedView.isHidden = true

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

        ownedView.isHidden = !(set.owned ?? false)
        wantedView.isHidden = !(set.wanted ?? false)

        let urlString = (UIScreen.main.scale > 1.5) ? set.largeThumbnailURL : set.thumbnailURL
        if let urlString = urlString, let url = URL(string: urlString) {
            setImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
        }

    }

}
