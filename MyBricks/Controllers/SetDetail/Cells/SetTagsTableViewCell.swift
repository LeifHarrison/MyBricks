//
//  SetTagsTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/9/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetTagsTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    static let nibName = "SetTagsTableViewCell"
    static let reuseIdentifier = "SetTagsTableViewCell"

    @IBOutlet weak var tagListView: TagListView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none

        addBorder()
        addGradientBackground()

        tagListView.cornerRadius = 4
        tagListView.marginY = 3
        tagListView.paddingX = 8
        tagListView.paddingY = 3
        tagListView.tagBackgroundColor = UIColor.lightNavy
        tagListView.textFont = UIFont.systemFont(ofSize: 14)
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagListView.removeAllTags()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with setDetail : SetDetail) -> Void {
        if let tags = setDetail.tags {
            tagListView.addTags(tags)
        }
    }
    
}
