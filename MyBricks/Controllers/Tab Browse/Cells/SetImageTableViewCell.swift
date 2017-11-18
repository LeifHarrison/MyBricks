//
//  SetImageTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SetImageTableViewCell: UITableViewCell {

    @IBOutlet weak var yearBackgroundView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var setImageView: UIImageView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        yearBackgroundView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        yearBackgroundView.layer.borderWidth = 1.0
        yearBackgroundView.layer.cornerRadius = yearBackgroundView.bounds.height / 2
        setImageView.contentMode = .scaleAspectFit
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        yearLabel.text = "0"
        setImageView.image = nil
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithSet(set : Set) -> Void {
        yearLabel.text = set.year
    }

}
