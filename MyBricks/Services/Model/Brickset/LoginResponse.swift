//
//  LoginResponse.swift
//  MyBricks
//
//  Created by Leif Harrison on 5/24/20.
//  Copyright © 2020 Leif Harrison. All rights reserved.
//

import Foundation

struct BricksetLoginResponse: Codable {
    
    var status: String
    var error: String?
    var hash: String?
    
}
