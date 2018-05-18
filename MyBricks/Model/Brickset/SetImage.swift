//
//  SetImage.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/1/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation
import Fuzi

public struct SetImage: Equatable {
    
    var thumbnailURL: String?
    var imageURL: String?

    init(thumbnailURL: String?, imageURL: String?) {
        self.thumbnailURL = thumbnailURL
        self.imageURL = imageURL
    }

    init?(element: XMLElement) {
        thumbnailURL = element.firstChild(tag: "thumbnailURL")?.stringValue
        imageURL = element.firstChild(tag: "imageURL")?.stringValue
    }
    
}
