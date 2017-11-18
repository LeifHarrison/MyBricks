//
//  SetReview.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import Foundation
import Fuzi

public struct SetReview {

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

    init?(element: XMLElement) {
        author = element.firstChild(tag: "author")?.stringValue
        title = element.firstChild(tag: "title")?.stringValue
        overallRating = Int(element.firstChild(tag: "overallRating")?.stringValue ?? "0")
        parts = Int(element.firstChild(tag: "parts")?.stringValue ?? "0")
        buildingExperience = Int(element.firstChild(tag: "buildingExperience")?.stringValue ?? "0")
        playability = Int(element.firstChild(tag: "playability")?.stringValue ?? "0")
        valueForMoney = Int(element.firstChild(tag: "valueForMoney")?.stringValue ?? "0")
        review = element.firstChild(tag: "review")?.stringValue
        isHTML = Bool(element.firstChild(tag: "HTML")?.stringValue ?? "false")

        if let date = element.firstChild(tag: "datePosted")?.stringValue {
            datePosted = BricksetServices.longDateFormatter.date(from: date)
        }
    }

}
