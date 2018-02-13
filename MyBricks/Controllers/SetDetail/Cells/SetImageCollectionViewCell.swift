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
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.transform = CGAffineTransform.identity
        imageView.image = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Properties
    //--------------------------------------------------------------------------
    
    override var isHighlighted: Bool{
        didSet {
            if self.isHighlighted {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            else {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
}
