//
//  Part.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/8/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct Part: Decodable {
    
    var partNumber: String?
    var name: String?
    var categoryId: Int?
    var partURL: String?
    var imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case partNumber = "part_num"
        case name
        case categoryId = "part_cat_id"
        case partURL = "part_url"
        case imageURL = "part_img_url"
    }

}
