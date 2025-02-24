//
//  NewsItemTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/31/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import AlamofireRSSParser

class NewsItemTableViewCell: BorderedGradientTableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var autherAndDateLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryView = UIImageView(image: UIImage(named:"disclosure"))
        accessoryView?.tintColor = UIColor.lightNavy
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with feedItem: RSSItem) {
        titleLabel.text = feedItem.title
        autherAndDateLabel.attributedText = feedItem.authorAndDateAttributedDecription()
    }
    
}

//==============================================================================
// MARK: - RSSItem extensions
//==============================================================================

extension RSSItem {
    
    static let templateAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light),
        NSAttributedString.Key.foregroundColor: UIColor.slateBlue
    ]
    static let authorAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.lightNavy
    ]
    static let dateFormatter = DateFormatter()
    
    func authorAndDateAttributedDecription() -> NSAttributedString {
        RSSItem.dateFormatter.dateStyle = .medium
        RSSItem.dateFormatter.timeStyle = .short
        
        let attributedDescription = NSMutableAttributedString(string:"Posted by ", attributes:RSSItem.templateAttributes)
        attributedDescription.append(NSAttributedString(string:author ?? "", attributes:RSSItem.authorAttributes))
        if let date = pubDate {
            attributedDescription.append(NSAttributedString(string:", \(RSSItem.dateFormatter.string(from: date))", attributes:RSSItem.templateAttributes))
        }
        
        return attributedDescription
    }

}
