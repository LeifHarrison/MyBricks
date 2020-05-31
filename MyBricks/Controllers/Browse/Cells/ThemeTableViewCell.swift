//
//  ThemeTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 8/1/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class ThemeTableViewCell: BorderedGradientTableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet weak var setCountContainer: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCountContainer.applyRoundedShadowStyle()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        accessoryType = .none
        selectionStyle = .none
        
        nameLabel.text = nil
        yearsLabel.text = nil
        setCountLabel.text = nil
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithTheme(_ theme: SetTheme) {
        nameLabel.text = theme.theme
        yearsLabel.text = theme.yearsDescription()

        if let setCount = theme.setCount, setCount > 0 {
            setCountLabel.text = "\(setCount)"
            selectionStyle = .default
        }
    }

}

//==============================================================================
// MARK: - SetTheme extensions
//==============================================================================

extension SetTheme {

    static let textColor = UIColor(white:0.1, alpha:1.0)
    static let regularAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: textColor]
    static let boldAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold), NSAttributedStringKey.foregroundColor: textColor]

    func setsAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string:"\( setCount ?? 0)", attributes:SetTheme.boldAttributes)
        attributedDescription.append(NSAttributedString(string:" sets", attributes:SetTheme.regularAttributes))
        if let subthemeCount = subthemeCount, subthemeCount > 0 {
            attributedDescription.append(NSAttributedString(string:", ", attributes:SetTheme.regularAttributes))
            attributedDescription.append(subthemesAttributedDescription())
        }

        return attributedDescription
    }

    func subthemesAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string:"\( subthemeCount ?? 0)", attributes:SetTheme.boldAttributes)
        attributedDescription.append(NSAttributedString(string:" subthemes", attributes:SetTheme.regularAttributes))
        return attributedDescription
    }

}
