//
//  SetDetailCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/26/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SetDetailCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var ownedContainer: UIView!
    @IBOutlet weak var wantedContainer: UIView!

    @IBOutlet weak var ownedCheckboxButton: UIButton!
    @IBOutlet weak var ownedCountField: UITextField!
    @IBOutlet weak var wantedCheckboxButton: UIButton!

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        ownedCheckboxButton.isSelected = false
        wantedCheckboxButton.isSelected = false
        ownedCountField.text = ""
    }
    
}
