//
//  RebrickableProfile.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/25/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

public struct RebrickableProfile: Decodable {
    
    var userId: Int
    var username: String
    var email: String
    var lastActivity: String
    var lastIP: String
    var location: String
    var collection: RebrickableCollection
    var avatarImageURL: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username = "username"
        case email = "email"
        case lastActivity = "last_activity"
        case lastIP = "last_ip"
        case location
        case collection = "lego"
        case avatarImageURL = "avatar_img"
    }
    
}
