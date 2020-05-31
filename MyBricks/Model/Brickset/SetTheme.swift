//
//  SetTheme.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

struct SetTheme: Codable {
    
    var theme: String
    var setCount: Int?
    var subthemeCount: Int?
    var yearFrom: Int?
    var yearTo: Int?
    
    func yearsDescription() -> String {
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

extension SetTheme: Equatable {
    
    static func == (lhs: SetTheme, rhs: SetTheme) -> Bool {
        return lhs.theme == rhs.theme
    }
    
}
