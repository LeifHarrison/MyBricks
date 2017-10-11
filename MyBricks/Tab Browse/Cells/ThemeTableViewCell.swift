//
//  ThemeTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 8/1/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
