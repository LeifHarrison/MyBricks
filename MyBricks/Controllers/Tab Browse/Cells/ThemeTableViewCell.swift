//
//  ThemeTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 8/1/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithTheme(_ theme: SetTheme) -> Void {
        nameLabel.text = theme.name
        yearsLabel.text = theme.yearsDecription()

        if let setCount = theme.setCount, setCount > 0 {
            setCountLabel.attributedText = theme.setsAttributedDescription()
            if setCount > 0 {
                selectionStyle = .default
                accessoryType = .disclosureIndicator
            }
        }
        else if let subthemeCount = theme.subThemeCount, subthemeCount > 0 {
            setCountLabel.attributedText = theme.subthemesAttributedDescription()
        }
        else {
            setCountLabel.text = ""
        }
    }

}

//==============================================================================
// MARK: - SetTheme extensions
//==============================================================================

extension SetTheme {

    static let textColor = UIColor(white:0.1, alpha:1.0)
    static let regularAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: textColor]
    static let boldAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .bold), NSAttributedStringKey.foregroundColor: textColor]

    func setsAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string:"\( setCount ?? 0)", attributes:SetTheme.boldAttributes)
        attributedDescription.append(NSAttributedString(string:" sets", attributes:SetTheme.regularAttributes))
        if let subthemeCount = subThemeCount, subthemeCount > 0 {
            attributedDescription.append(NSAttributedString(string:", ", attributes:SetTheme.regularAttributes))
            attributedDescription.append(subthemesAttributedDescription())
        }

        return attributedDescription
    }

    func subthemesAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string:"\( subThemeCount ?? 0)", attributes:SetTheme.boldAttributes)
        attributedDescription.append(NSAttributedString(string:" subthemes", attributes:SetTheme.regularAttributes))
        return attributedDescription
    }

}
