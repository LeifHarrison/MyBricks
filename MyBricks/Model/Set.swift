//
//  Set.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import Foundation
import Fuzi

public struct Set {

    var setID: String?
    var number: String?
    var name: String?
    var year: String?
    var theme: String?
    var subtheme: String?
    var pieces: Int?
    var minifigs: Int?
    var thumbnailURL: String?
    var largeThumbnailURL: String?
    var imageURL: String?
    var bricksetURL: String?
    var packagingType: String?
    var availability: String?
    var EAN: String?
    var UPC: String?

    init?(element: XMLElement) {
        setID = element.firstChild(tag: "setID")?.stringValue
        number = element.firstChild(tag: "number")?.stringValue
        name = element.firstChild(tag: "name")?.stringValue
        year = element.firstChild(tag: "year")?.stringValue
        theme = element.firstChild(tag: "theme")?.stringValue
        subtheme = element.firstChild(tag: "subtheme")?.stringValue
        pieces = Int(element.firstChild(tag: "pieces")?.stringValue ?? "0")
        minifigs = Int(element.firstChild(tag: "minifigs")?.stringValue ?? "0")
        thumbnailURL = element.firstChild(tag: "thumbnailURL")?.stringValue
        largeThumbnailURL = element.firstChild(tag: "largeThumbnailURL")?.stringValue
        imageURL = element.firstChild(tag: "imageURL")?.stringValue
        bricksetURL = element.firstChild(tag: "bricksetURL")?.stringValue
        packagingType = element.firstChild(tag: "packagingType")?.stringValue
        availability = element.firstChild(tag: "availability")?.stringValue
        EAN = element.firstChild(tag: "EAN")?.stringValue
        UPC = element.firstChild(tag: "UPC")?.stringValue
     }

}

