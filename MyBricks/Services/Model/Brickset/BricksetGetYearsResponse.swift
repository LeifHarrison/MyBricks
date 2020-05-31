//
//  BricksetGetYearsResponse.swift
//  MyBricks
//
//  Created by Leif Harrison on 5/30/20.
//  Copyright © 2020 Leif Harrison. All rights reserved.
//

import Foundation

struct BricksetGetYearsResponse: Decodable {
    
    var status: String
    var message: String?

    var matches: Int?
    var years: [SetYear]?
    
}
