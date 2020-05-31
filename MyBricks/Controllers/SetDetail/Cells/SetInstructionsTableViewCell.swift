//
//  SetInstructionsTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/27/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetInstructionsTableViewCell: BlueGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var instructionsCountLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()

        accessoryView = UIImageView(image: UIImage(named:"disclosure"))
        accessoryView?.tintColor = UIColor.lightNavy
        
        instructionsTitleLabel.text = NSLocalizedString("Instructions", comment: "")
        
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        instructionsCountLabel.text = "N/A"
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with set: SetDetail) {
        instructionsCountLabel.text = "\(set.instructionsCount ?? 0)"
    }
    
}
