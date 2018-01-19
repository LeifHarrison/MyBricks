//
//  SetDescriptionTableViewCell.swift
//  MyBricks
//
//  Created by Leif on 11/26/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionTextView: UITextView!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    
    func populate(with setDetail : SetDetail) -> Void {
        descriptionTextView.attributedText = setDetail.formattedDescription()
    }

}

//==============================================================================
// MARK: - SetDetail extension
//==============================================================================

extension SetDetail {
    
    static let textColor = UIColor(white:0.1, alpha:1.0)
    static let templateAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: textColor]
    static let authorAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.blue]
    
    func formattedDescription() -> NSAttributedString? {
        if let string = self.setDescription {
            if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                let options: [NSAttributedString.DocumentReadingOptionKey:Any] = [
                    .documentType:NSAttributedString.DocumentType.html,
                    .characterEncoding:String.Encoding.utf8.rawValue
                ]
                
                var formattedReview = NSMutableAttributedString()
                do {
                    formattedReview = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
                }
                catch {
                    return nil
                }
                
                formattedReview.beginEditing()
                
                // Change fonts to something a bit more readable
                let fullRange = NSMakeRange(0, formattedReview.length)
                formattedReview.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                    if let font = value as? UIFont {
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        
                        let size: CGFloat = 14
                        
                        var font = UIFont.systemFont(ofSize: size)
                        if isBold {
                            font = UIFont.boldSystemFont(ofSize: size)
                        }
                        else if isItalic {
                            font = UIFont.italicSystemFont(ofSize: size)
                        }
                        formattedReview.addAttribute(.font, value: font, range: range)
                    }
                }
                
                formattedReview.endEditing()
                
                return formattedReview
            }
        }
        return nil
    }
}
