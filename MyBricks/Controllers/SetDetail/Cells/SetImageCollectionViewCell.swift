//
//  SetImageCollectionViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/6/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetImageCollectionViewCell: UICollectionViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var imageView: UIImageView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 4.0
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = isSelected ? UIColor.lightNavy.cgColor : nil
            self.layer.borderWidth = isSelected ? 2 : 0
        }
    }
}
