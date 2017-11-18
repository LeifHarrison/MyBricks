//
//  SetRetailPrice.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import Foundation

public struct SetRetailPrice {

    var locale: Locale
    var price: String

    init(locale: Locale, price: String) {
        self.locale = locale
        self.price = price
    }

}
