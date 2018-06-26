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
    var nextPage: String?
    var previousPage: String?
    var results: [Element]?
    
    enum CodingKeys: String, CodingKey {
        case count
        case nextPage = "next"
        case previousPage = "previous"
        case results
    }
    
}
