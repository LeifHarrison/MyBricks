//
//  SetTheme.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

public struct SetTheme {

    var name: String?
    var setCount: Int?
    var subThemeCount: Int?
    var yearFrom: Int?
    var yearTo: Int?

    init?(element: XMLElement) {
        self.name = element.firstChild(tag: "theme")?.stringValue
        setCount = Int(element.firstChild(tag: "setCount")?.stringValue ?? "0")
        subThemeCount = Int(element.firstChild(tag: "subThemeCount")?.stringValue ?? "0")
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
