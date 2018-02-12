//
//  SetTagsTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/9/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetTagsTableViewCell: UITableViewCell {

    static let nibName = "SetTagsTableViewCell"
    static let reuseIdentifier = "SetTagsTableViewCell"

    @IBOutlet weak var tagListView: TagListView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let font = UIFont.systemFont(ofSize: 16)
        tagListView.textFont = font
        tagListView.marginY = 3
        tagListView.paddingX = (font.lineHeight / 2) + tagListView.paddingY
        tagListView.paddingY = 3
        tagListView.cornerRadius = tagListView.paddingX
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
