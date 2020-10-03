//
//  Decimal+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/5/20.
//  Copyright © 2020 Leif Harrison. All rights reserved.
//

import Foundation

extension Decimal {
    
    mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
