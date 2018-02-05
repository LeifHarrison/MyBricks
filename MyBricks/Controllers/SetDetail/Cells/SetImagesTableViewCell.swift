//
//  SetImagesTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/2/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    
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
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSetImages(_ images : [SetImage]) -> Void {
        var previousImageView: UIImageView? = nil
        for image in images {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            
            imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
            if let previousImageView = previousImageView {
                imageView.leadingAnchor.constraint(equalTo: previousImageView.trailingAnchor, constant: 10).isActive = true
            }
            else {
                imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            }
            previousImageView = imageView
            
            if let thumbnailURLString = image.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
                imageView.af_setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3)) { response in
                    //if let image = response.result.value {
                    //    print("thumbnail size = \(image.size)")
                    //}
                }
            }
        }
        
        if let lastImageView = previousImageView {
            scrollView.trailingAnchor.constraint(equalTo: lastImageView.trailingAnchor).isActive = true
        }

    }
    
}
