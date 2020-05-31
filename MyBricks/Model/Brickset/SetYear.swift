//
//  SetYear.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

struct SetYear: Codable {

    var theme: String
    var year: String
    var setCount: Int?

}

extension SetYear: Equatable {
    
    static func == (lhs: SetYear, rhs: SetYear) -> Bool {
        return lhs.theme == rhs.theme && lhs.year == rhs.year
    }
    
}
