//
//  SetDetailTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailTableViewCell: UITableViewCell {

    static let nibName = "SetDetailTableViewCell"
    static let reuseIdentifier = "SetDetailTableViewCell"

    @IBOutlet weak var setNameField: UILabel!
    @IBOutlet weak var themeGroupField: UILabel!
    @IBOutlet weak var themeField: UILabel!
    @IBOutlet weak var availabilityField: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        setNameField.text = ""
        themeGroupField.text = "0"
        themeField.text = "0"
        availabilityField.text = "0"
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        setNameField.text = set.name
        themeField.text = set.themeDetail()
        themeGroupField.text = set.themeGroup?.capitalized
        availabilityField.text = set.availabilityDetail()

        // Future additions, hopefully...
        //setTypeField.text = "-"
        //tagsField.text = "-"
    }

}
