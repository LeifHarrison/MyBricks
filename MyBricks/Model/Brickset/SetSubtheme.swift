//
//  SetSubtheme.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

struct SetSubtheme: Codable {

    var theme: String
    var subtheme: String
    var setCount: Int?
    var yearFrom: Int?
    var yearTo: Int?

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
        return lhs.theme == rhs.theme && lhs.subtheme == rhs.subtheme
    }
    
}
