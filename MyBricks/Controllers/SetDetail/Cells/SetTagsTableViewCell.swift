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
        setupTagListView()
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
    
    func populate(with setDetail: SetDetail) {
        if let tags = setDetail.tags {
            tagListView.addTags(tags)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    private func setupTagListView() {
        tagListView.cornerRadius = 11
        tagListView.marginY = 5
        tagListView.paddingX = 10
        tagListView.paddingY = 5
        tagListView.tagBackgroundColor = UIColor.lightNavy
        tagListView.textFont = UIFont.systemFont(ofSize: 14)
    }
    
}
