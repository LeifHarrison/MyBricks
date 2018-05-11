//
//  BrowseHeaderView.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/15/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class BrowseHeaderView: UIView {

    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var divider: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
        
        layer.shadowColor = UIColor(white: 0.8, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.5

        resultsLabel.text = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    // swiftlint:disable cyclomatic_complexity

    func populate(with setCount: Int, filterOptions: FilterOptions?) {
        let regularTextColor = UIColor.white
        let boldTextColor = UIColor.white
        let regularAttributes: [NSAttributedStringKey: Any] = [ .font : resultsLabel.font, .foregroundColor : regularTextColor]
        let boldAttributes: [NSAttributedStringKey: Any] = [ .font : resultsLabel.font.bold(), .foregroundColor : boldTextColor]
        let separator = NSAttributedString(string:" : ", attributes:regularAttributes)
        
        let attributedDescription = NSMutableAttributedString(string:"Showing ", attributes:regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(setCount) \(setCount > 1 ? "sets" : "set")", attributes:boldAttributes))
        if let options = filterOptions, options.hasSelectedFilters() {
            attributedDescription.append(NSAttributedString(string:" matching ", attributes:regularAttributes))
            let filterString = NSMutableAttributedString()
            if let searchTerm = options.searchTerm {
                filterString.append(NSAttributedString(string:"\"\(searchTerm)\"", attributes:boldAttributes))
            }
            if options.showingUserSets, let theme = options.selectedTheme {
                if filterString.length > 0 { filterString.append(separator) }
                filterString.append(NSAttributedString(string:"\(theme.name)", attributes:boldAttributes))
            }
            if let subtheme = options.selectedSubtheme {
                if filterString.length > 0 { filterString.append(separator) }
                filterString.append(NSAttributedString(string:"\(subtheme.name)", attributes:boldAttributes))
            }
            if let year = options.selectedYear {
                if filterString.length > 0 { filterString.append(separator) }
                filterString.append(NSAttributedString(string:"\(year.name)", attributes:boldAttributes))
            }
            if options.filterOwned {
                if filterString.length > 0 { filterString.append(separator) }
                filterString.append(NSAttributedString(string:"Owned", attributes:boldAttributes))
            }
            if options.filterNotOwned {
                if filterString.length > 0 { filterString.append(separator) }
                filterString.append(NSAttributedString(string:"Not Owned", attributes:boldAttributes))
            }
            if options.filterWanted {
                if filterString.length > 0 { filterString.append(separator) }
                filterString.append(NSAttributedString(string:"Wanted", attributes:boldAttributes))
            }
            
            attributedDescription.append(filterString)
        }
        
        resultsLabel.attributedText = attributedDescription
        layoutIfNeeded()
    }
    
    // swiftlint:enable cyclomatic_complexity

}
