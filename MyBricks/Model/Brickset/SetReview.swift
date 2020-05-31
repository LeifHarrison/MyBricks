//
//  SetReview.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct SetReview: Codable {

    var author: String?
    var datePosted: Date?
    var title: String?
    var overallRating: Int?
    var parts: Int?
    var buildingExperience: Int?
    var playability: Int?
    var valueForMoney: Int?
    var review: String?
    var isHTML: Bool?

}
