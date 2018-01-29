//
//  Color.swift
//  MyBricks
//
//  Created by Leif on 12/8/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct Color: Decodable {
    
    var id: Int?
    var isTransparent: Bool?
    var name: String?
    var hexColor: String?
    
    enum CodingKeys : String, CodingKey {
        case id
        case isTransparent = "is_trans"
        case name
        case hexColor = "rgb"
    }

}
