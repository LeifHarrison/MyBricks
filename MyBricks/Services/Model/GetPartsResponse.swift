//
//  GetPartsResponse.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct GetPartsResponse: Decodable {
    
    var count: Int?
    var results: [Element]?
    
    enum CodingKeys : String, CodingKey {
        case count
        case results
    }
    
}
