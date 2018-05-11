//
//  UIFont+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/12/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

extension UIFont {
    
    func withTraits(traits: UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
}
