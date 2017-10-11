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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setImageView.image = nil
        nameLabel.text = ""
        setNumberLabel.text = ""
    }
}
