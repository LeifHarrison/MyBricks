//
//  Element.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/8/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct Element: Decodable {

    var partId: Int?
    var inventoryPartId: Int?
    var part: Part?
    var color: Color?
    var quantity: Int?
    var isSpare: Bool?
    var elementId: String?
    var numberOfSets: Int?

    enum CodingKeys: String, CodingKey {
        case partId = "id"
        case inventoryPartId = "inv_part_id"
        case part
        case color
        case quantity
        case isSpare = "is_spare"
        case elementId = "element_id"
        case numberOfSets = "num_sets"
    }

}
