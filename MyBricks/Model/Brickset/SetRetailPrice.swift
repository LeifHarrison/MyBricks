//
//  SetRetailPrice.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct SetRetailPrice: Codable {

    static var PricePerPieceFormatter = NumberFormatter()
    
    var locale: Locale
    var price: Decimal
    var pricePerPiece: Decimal

    func priceDescription() -> String {
        let currencySymbol = locale.currencySymbol ?? "$"
        return currencySymbol + "\(price)"
    }

    func pricePerPieceDescription() -> String {
        let currencySymbol = locale.currencySymbol ?? "$"
        return currencySymbol + "\(pricePerPiece)" + " / piece"
    }

}
