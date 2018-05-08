//
//  ThemeTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 8/1/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    @IBOutlet weak var setCountLabel: UILabel!
    @IBOutlet weak var setCountContainer: UIView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tintColor = UIColor.lightNavy
        
        addBorder()
        addGradientBackground()

        //setCountContainer.layer.borderColor = UIColor.whiteThree.cgColor
        //setCountContainer.layer.borderWidth = 1.0
        setCountContainer.layer.cornerRadius = setCountContainer.frame.height / 2
        setCountContainer.layer.shadowColor = UIColor.blueGrey.cgColor
        setCountContainer.layer.shadowRadius = 2
        setCountContainer.layer.shadowOpacity = 0.7
        setCountContainer.layer.shadowOffset =  CGSize(width: 1, height: 1)
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

    func populateWithTheme(_ theme: SetTheme) -> Void {
        nameLabel.text = theme.name
        yearsLabel.text = theme.yearsDecription()

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
