//
//  BricksetGetSubthemesResponse.swift
//  MyBricks
//
//  Created by Leif Harrison on 5/25/20.
//  Copyright © 2020 Leif Harrison. All rights reserved.
//

import Foundation

struct BricksetGetSubthemesResponse: Decodable {
    
    var status: String
    var message: String?

    var matches: Int?
    var subthemes: [SetSubtheme]?
    
}
