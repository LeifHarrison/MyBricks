//
//  RebrickableCollection.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/25/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

public struct RebrickableCollection: Decodable {
    var lostSetParts: Int
    var totalSetParts: Int
    var totalSets: Int
    var allParts: Int
    var totalLooseParts: Int

    enum CodingKeys: String, CodingKey {
        case lostSetParts = "lost_set_parts"
        case totalSetParts = "total_set_parts"
        case totalSets = "total_sets"
        case allParts = "all_parts"
        case totalLooseParts = "total_loose_parts"
    }

}
