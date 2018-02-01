//
//  InstructionsTableViewCell.swift
//  MyBricks
//
//  Created by Leif on 11/25/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class InstructionsTableViewCell: UITableViewCell {

    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    var previewButtonTapped : (() -> Void)? = nil

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
        filenameLabel.text = nil
        titleLabel.text = nil
        progressView.isHidden = true
        progressView.progress = 0.0
        previewButtonTapped = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func previewButtonTapped(_ sender: UIButton) {
        previewButtonTapped?()
    }
    
}
