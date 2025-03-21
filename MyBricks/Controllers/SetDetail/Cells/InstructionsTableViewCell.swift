//
//  InstructionsTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/25/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class InstructionsTableViewCell: BorderedGradientTableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    var previewButtonTapped: (() -> Void)?

    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }

    // -------------------------------------------------------------------------
    // MARK: - Reuse
    // -------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        filenameLabel.text = nil
        titleLabel.text = nil
        progressView.isHidden = true
        progressView.progress = 0.0
        previewButtonTapped = nil
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------
    
    @IBAction func previewButtonTapped(_ sender: UIButton) {
        previewButtonTapped?()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------

    func populate(with instructions: SetInstructions) {
        if let urlString = instructions.fileURL, let url = URL(string: urlString) {
            filenameLabel.text = url.lastPathComponent
            if let destination = instructions.destinationURL, FileManager.default.fileExists(atPath: destination.path) {
                previewButton.imageView?.image = #imageLiteral(resourceName: "documentView")
            }
            else {
                previewButton.imageView?.image = #imageLiteral(resourceName: "documentDownload")
            }
        }
        titleLabel.text = instructions.fileDescription
    }
}
