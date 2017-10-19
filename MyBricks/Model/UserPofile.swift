//
//  UserPofile.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import Foundation
import Fuzi

public struct UserProfile {

    var name: String?
    var memberSince: Date?
    var lastOnline: Date?
    var country: String?
    var location: String?
    var interests: String?

    init?(element: XMLElement) {
    }

}
