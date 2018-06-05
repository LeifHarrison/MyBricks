//
//  BricksetProfileTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/8/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class BricksetProfileTableViewCell: BorderedGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    var loginButtonTapped : (() -> Void)?

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        loginButton.applyDefaultStyle()
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        loginButtonTapped?()
    }
    
}
