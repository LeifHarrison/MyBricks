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
        //imageView.layer.borderColor = UIColor.whiteThree.cgColor
        //imageView.layer.borderWidth = 1.0 / UIScreen.main.scale

    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
