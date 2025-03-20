//
//  UILabel+Extensions.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/2/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

extension UILabel {
    
    func applyInstructionsStyle() {
        textColor = UIColor.lightNavy
        font = UIFont.systemFont(ofSize: 16)
        
        let instructionsText = NSMutableAttributedString(string: self.text ?? "")
        let range = NSRange(location: 0, length: instructionsText.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 5
        paragraphStyle.paragraphSpacingBefore = 5
        instructionsText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        instructionsText.addAttribute(.kern, value: 0.2, range: range)
        self.attributedText = instructionsText
    }
    
}
