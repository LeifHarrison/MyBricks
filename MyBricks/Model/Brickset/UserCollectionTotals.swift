//
//  UserCollectionTotals.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/16/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation

public struct UserCollectionTotals: Codable {

    var totalSetsOwned: Int?
    var totalDistinctSetsOwned: Int?
    var totalSetsWanted: Int?
    var totalMinifigsOwned: Int?
    var totalDistinctMinifigsOwned: Int?
    var totalMinifigsWanted: Int?

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
