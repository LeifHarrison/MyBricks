//
//  SetTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {

    @IBOutlet weak var setImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var subthemeLabel: UILabel!
    @IBOutlet weak var piecesLabel: UILabel!
    @IBOutlet weak var minifigsLabel: UILabel!

    @IBOutlet weak var retiredView: UIView!
    @IBOutlet weak var ownedView: UIView!
    @IBOutlet weak var wantedView: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()

        retiredView.layer.cornerRadius = retiredView.bounds.height / 2
        ownedView.layer.cornerRadius = ownedView.bounds.height / 2
        wantedView.layer.cornerRadius = ownedView.bounds.height / 2
    }
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setImageView.image = nil
        nameLabel.text = ""
        setNumberLabel.text = ""
        subthemeLabel.text = ""
        piecesLabel.text = "0"
        minifigsLabel.text = "0"

        retiredView.isHidden = true
        ownedView.isHidden = true
        wantedView.isHidden = true
    }
}
