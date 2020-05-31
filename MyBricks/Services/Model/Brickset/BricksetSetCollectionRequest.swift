//
//  BricksetSetCollectionRequest.swift
//  MyBricks
//
//  Created by Leif Harrison on 5/31/20.
//  Copyright © 2020 Leif Harrison. All rights reserved.
//

import Foundation

public struct BricksetSetCollectionRequest: Encodable {

    var own: Bool?
    var want: Bool?
    var qtyOwned: Int?
    var notes: String?
    var rating: Int?
    
}
