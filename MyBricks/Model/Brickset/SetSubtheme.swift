//
//  SetSubtheme.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

struct SetSubtheme {

    var theme: String
    var name: String
    var setCount: Int?
    var yearFrom: Int?
    var yearTo: Int?

    init?(element: XMLElement) {
        guard let xmlTheme = element.firstChild(tag: "theme")?.stringValue, let xmlSubtheme = element.firstChild(tag: "subtheme")?.stringValue else {
            return nil
        }
        
        theme = xmlTheme
        name = xmlSubtheme
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

extension SetSubtheme: Equatable {
    
    static func == (lhs: SetSubtheme, rhs: SetSubtheme) -> Bool {
        return lhs.theme == rhs.theme && lhs.name == rhs.name
    }
    
}
