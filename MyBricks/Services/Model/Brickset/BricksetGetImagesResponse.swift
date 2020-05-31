//
//  BricksetGetImagesResponse.swift
//  MyBricks
//
//  Created by Leif Harrison on 5/28/20.
//  Copyright © 2020 Leif Harrison. All rights reserved.
//

import Foundation

struct BricksetGetImagesResponse: Decodable {
    
    var status: String
    var message: String?
    var matches: Int?
    var additionalImages: [SetImage]?
    
}
