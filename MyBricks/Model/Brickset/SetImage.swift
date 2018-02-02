//
//  SetImage.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/1/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

public struct SetImage {
    
    var thumbnailURL: String?
    var imageURL: String?
    
    init?(element: XMLElement) {
        thumbnailURL = element.firstChild(tag: "thumbnailURL")?.stringValue
        imageURL = element.firstChild(tag: "imageURL")?.stringValue
    }
    
}
