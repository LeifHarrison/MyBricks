//
//  SetRetailPrice.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct SetRetailPrice {

    static var PricePerPieceFormatter = NumberFormatter()
    
    var locale: Locale
    var price: String
    var pricePerPiece: String

    init(locale: Locale, price: String, pricePerPiece: String) {
        self.locale = locale
        self.price = price
        self.pricePerPiece = pricePerPiece
    }

    func priceDescription() -> String {
        let currencySymbol = locale.currencySymbol ?? "$"
        return (price.count > 0) ? (currencySymbol + price) : "PRICE N/A"
    }

    func pricePerPieceDescription() -> String {
        return (price.count > 0) ? (pricePerPiece + " / piece") : ""
    }

}
