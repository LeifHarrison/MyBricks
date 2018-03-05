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
        let flag = locale.emojiFlag ?? "🇺🇸"
        let currencySymbol = locale.currencySymbol ?? "$"
        if price.count > 0 {
            return (currencySymbol + price + " " + flag)
        }
        else {
            return (currencySymbol + " N/A" + " " + flag)
        }
    }

    func pricePerPieceDescription() -> String {
        if price.count > 0 {
            return pricePerPiece + " / piece"
        }
        else {
            return ""
        }
    }

}
