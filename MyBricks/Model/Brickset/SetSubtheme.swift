//
//  SetSubtheme.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

public struct SetSubtheme {

    var theme: String
    var subtheme: String
    var setCount: Int?
    var yearFrom: Int?
    var yearTo: Int?

    init?(element: XMLElement) {
        guard let xmlTheme = element.firstChild(tag: "theme")?.stringValue, let xmlSubtheme = element.firstChild(tag: "theme")?.stringValue else {
            return nil
        }
        
        theme = xmlTheme
        subtheme = xmlSubtheme
        setCount = Int(element.firstChild(tag: "setCount")?.stringValue ?? "0")
        yearFrom = Int(element.firstChild(tag: "yearFrom")?.stringValue ?? "0")
        yearTo = Int(element.firstChild(tag: "yearTo")?.stringValue ?? "0")
    }

    func yearsDecription() -> String {
        if let yearFrom = yearFrom, let yearTo = yearTo, yearTo != yearFrom {
            return "\(yearFrom) - \(yearTo)"
        }
        else if let yearFrom = yearFrom {
            return "\(yearFrom)"
        }
        else if let yearTo = yearTo {
            return "\(yearTo)"
        }
        else {
            return ""
        }
    }
    
}
