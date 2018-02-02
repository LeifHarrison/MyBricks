//
//  AdditionalImagesTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/2/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class AdditionalImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
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
        // Clear stack view
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSetImages(_ images : [SetImage]) -> Void {
        for image in images {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            if let thumbnailURLString = image.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
                imageView.af_setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3))
            }
            stackView.addArrangedSubview(imageView)
        }
    }
    
}
