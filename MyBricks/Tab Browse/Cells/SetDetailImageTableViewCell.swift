//
//  SetImageTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SetDetailImageTableViewCell: UITableViewCell {

    @IBOutlet weak var setImageView: UIImageView!

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setImageView.image = nil
    }

}
