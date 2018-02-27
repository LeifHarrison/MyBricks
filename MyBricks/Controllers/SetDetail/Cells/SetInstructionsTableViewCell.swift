//
//  SetInstructionsTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/27/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetInstructionsTableViewCell: UITableViewCell, ReusableView, NibLoadableView  {

    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var instructionsImageView: UIImageView!
    @IBOutlet weak var instructionsCountLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    func populateWithSet(_ set : Set) -> Void {
        instructionsCountLabel.text = "\(set.instructionsCount ?? 0)"
    }
    
}
