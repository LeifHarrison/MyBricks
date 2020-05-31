//
//  SetTagsTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/9/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetTagsTableViewCell: BlueGradientTableViewCell, ReusableView, NibLoadableView {

    static let nibName = "SetTagsTableViewCell"
    static let reuseIdentifier = "SetTagsTableViewCell"

    @IBOutlet weak var tagListView: TagListView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
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
        if let tags = setDetail.extendedData?.tags {
            tagListView.addTags(tags)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    private func setupTagListView() {
        tagListView.cornerRadius = 14
        tagListView.marginY = 5
        tagListView.paddingX = 13
        tagListView.paddingY = 7
        tagListView.tagBackgroundColor = UIColor.lightNavy
        tagListView.textFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
    
}
