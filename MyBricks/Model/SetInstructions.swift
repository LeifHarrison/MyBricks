//
//  SetInstructions.swift
//  MyBricks
//
//  Created by Leif on 11/25/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

public struct SetInstructions {
    
    var description: String?
    var url: String?
    
    init?(element: XMLElement) {
        description = element.firstChild(tag: "description")?.stringValue
        url = element.firstChild(tag: "URL")?.stringValue
    }

}
