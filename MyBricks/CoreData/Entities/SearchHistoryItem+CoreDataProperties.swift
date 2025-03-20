//
//  SearchHistoryItem+CoreDataProperties.swift
//  MyBricks
//
//  Created by Leif Harrison on 12/3/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import Foundation
import CoreData

enum SearchType: Int16 {
    case scan
    case search
}

extension SearchHistoryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistoryItem> {
        return NSFetchRequest<SearchHistoryItem>(entityName: "SearchHistoryItem")
    }

    @NSManaged public var searchDate: NSDate
    @NSManaged public var searchTerm: String
    @NSManaged public var searchTypeValue: Int16

    var searchType: SearchType {
        get {
            return SearchType(rawValue: self.searchTypeValue)!
        }
        set {
            self.searchTypeValue = newValue.rawValue
        }
    }

    var iconName: String {
        switch searchType {
            case .search: return "search"
            case .scan: return "scan"
        }
    }
    
}
