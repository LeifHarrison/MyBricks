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
    var notes: String?
    var tags: [String]?
    var lastUpdated: Date?

    init?(element: XMLElement) {
        // XML for this is essentially identical to Set, but we're only really
        // interested in the description
        setID = element.firstChild(tag: "setID")?.stringValue
        setDescription = element.firstChild(tag: "description")?.stringValue
        notes = element.firstChild(tag: "notes")?.stringValue
        if let tagsString = element.firstChild(tag: "tags")?.stringValue {
            tags = tagsString.components(separatedBy: ",")
        }
        if let lastUpdatedString = element.firstChild(tag: "lastUpdated")?.stringValue {
            lastUpdated = BricksetServices.longDateFormatter.date(from: lastUpdatedString)
        }
    }

}
