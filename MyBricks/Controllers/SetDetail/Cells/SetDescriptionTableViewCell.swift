//
//  SetDescriptionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/26/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDescriptionTableViewCell: BlueGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var descriptionTextView: UITextView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionTextView.text = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with setDetail: SetDetail) {
        descriptionTextView.attributedText = setDetail.formattedDescription()
    }

}

//==============================================================================
// MARK: - SetDetail extension
//==============================================================================

// swiftlint:disable unused_closure_parameter

extension SetDetail {
    
    static let descriptionFontSize: CGFloat = 14

    func formattedDescription() -> NSAttributedString? {
        if let string = self.setDescription {
            if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType : NSAttributedString.DocumentType.html,
                    .characterEncoding : String.Encoding.utf8.rawValue
                ]
                
                var formattedDescription = NSMutableAttributedString()
                do {
                    formattedDescription = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
                }
                catch {
                    return nil
                }
                
                formattedDescription.beginEditing()
                
                // Change fonts to something a bit more readable
                let fullRange = NSRange(location: 0, length:formattedDescription.length)
                formattedDescription.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                    if let font = value as? UIFont {
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        
                        let size: CGFloat = SetDetail.descriptionFontSize
                        
                        var font = UIFont.systemFont(ofSize: size)
                        if isBold {
                            font = UIFont.boldSystemFont(ofSize: size)
                        }
                        else if isItalic {
                            font = UIFont.italicSystemFont(ofSize: size)
                        }
                        formattedDescription.addAttribute(.font, value: font, range: range)
                    }
                }
                
                // Change text color
                formattedDescription.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { (value, range, stop) in
                    formattedDescription.addAttribute(.foregroundColor, value: UIColor.lightNavy, range: range)
                }
                
                formattedDescription.endEditing()
                
                return formattedDescription
            }
        }
        return nil
    }
}

// swiftlint:enable unused_closure_parameter
