//
//  GetThemesResponse.swift
//  MyBricks
//
//  Created by Leif Harrison on 5/23/20.
//  Copyright © 2020 Leif Harrison. All rights reserved.
//

import Foundation

struct BricksetGetThemesResponse: Decodable {
    
    var status: String
    var message: String?

    var matches: Int?
    var themes: [SetTheme]?
    
}
