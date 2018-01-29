//
//  SetDetail.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/13/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

public struct SetDetail {

    var setID: String?
    var setDescription: String?
    var lastUpdated: Date?

    init?(element: XMLElement) {
        // XML for this is essentially identical to Set, but we're only really
        // interested in the description
        setID = element.firstChild(tag: "setID")?.stringValue
        setDescription = element.firstChild(tag: "description")?.stringValue
    }

}
