//
//  SetYear.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

public struct SetYear {

    var theme: String
    var year: String
    var setCount: Int?

    init?(element: XMLElement) {
        guard let xmlTheme = element.firstChild(tag: "theme")?.stringValue, let xmlYear = element.firstChild(tag: "year")?.stringValue else {
            return nil
        }
        
        theme = xmlTheme
        year = xmlYear

        setCount = Int(element.firstChild(tag: "setCount")?.stringValue ?? "0")
    }

}
