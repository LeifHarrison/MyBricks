//
//  Locale+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import Foundation

extension Locale {

    var emojiFlag: String? {
        if let code = regionCode {
            let base: UInt32 = 127397
            return String(String.UnicodeScalarView(code.unicodeScalars.flatMap({ UnicodeScalar(base + $0.value) })))
        }
        return nil
    }

}
