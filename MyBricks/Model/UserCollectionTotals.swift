//
//  UserCollectionTotals.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/16/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import Foundation
import Fuzi

public struct UserCollectionTotals {

    var totalSetsOwned: Int?
    var totalDistinctSetsOwned: Int?
    var totalSetsWanted: Int?
    var totalMinifigsOwned: Int?
    var totalDistinctMinifigsOwned: Int?
    var totalMinifigsWanted: Int?

    init?(element: XMLElement) {
        totalSetsOwned = Int(element.firstChild(tag: "totalSetsOwned")?.stringValue ?? "0")
        totalDistinctSetsOwned = Int(element.firstChild(tag: "totalDistinctSetsOwned")?.stringValue ?? "0")
        totalSetsWanted = Int(element.firstChild(tag: "totalSetsWanted")?.stringValue ?? "0")
        totalMinifigsOwned = Int(element.firstChild(tag: "totalMinifigsOwned")?.stringValue ?? "0")
        totalDistinctMinifigsOwned = Int(element.firstChild(tag: "totalDistinctMinifigsOwned")?.stringValue ?? "0")
        totalMinifigsWanted = Int(element.firstChild(tag: "totalMinifigsWanted")?.stringValue ?? "0")
    }

    func setsOwnedDescription() -> String {
        return "You own \(totalSetsOwned ?? 0) sets, \(totalDistinctSetsOwned ?? 0) different"
    }

    func setsWantedDescription() -> String {
        return "You want \(totalSetsWanted ?? 0) sets"
    }

    func minifigsOwnedDescription() -> String {
        return "You own \(totalMinifigsOwned ?? 0) minifigs, \(totalDistinctMinifigsOwned ?? 0) different"
    }

    func minifigsWantedDescription() -> String {
        return "You want \(totalMinifigsWanted ?? 0) minifigs"
    }

}
