//
//  MySetsHeaderView.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/6/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class MySetsHeaderView: UIView {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var dividerView: UIView!

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showButtonContainer: UIView!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var groupButtonContainer: UIView!
    @IBOutlet weak var groupButton: UIButton!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()

        //showButton.layer.borderColor = UIColor.darkGray.cgColor
        //showButton.layer.borderWidth = 1.0
        showButtonContainer.layer.cornerRadius = showButtonContainer.bounds.height / 2
        groupButtonContainer.layer.cornerRadius = groupButtonContainer.bounds.height / 2
    }

}
