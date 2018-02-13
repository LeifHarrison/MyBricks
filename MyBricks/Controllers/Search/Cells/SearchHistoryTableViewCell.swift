//
//  SearchHistoryTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/3/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SearchHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var searchTypeImageView: UIImageView!
    @IBOutlet weak var searchTermLabel: UILabel!
    
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
        searchTermLabel.text = nil
        searchTypeImageView.image = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSearchHistoryItem(_ item : SearchHistoryItem) -> Void {
        searchTypeImageView.image = UIImage(named: item.iconName)
        searchTermLabel.text = item.searchTerm
    }
    
}
