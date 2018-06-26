//
//  GetSetsRequest.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/4/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

enum SortingType: String {
    case number = "Number"
    case yearFrom = "YearFrom"
    case pieces = "Pieces"
    case minifigs = "Minifigs"
    case rating = "Rating"
    case retailPrice = "RetailPrice"
    case theme = "Theme"
    case subtheme = "Subtheme"
    case name = "Name"
    case random = "Random"
    
    static let allValues: [SortingType] = [ .number, .yearFrom, .pieces, .minifigs, .rating, .retailPrice, .theme, .subtheme, .name, .random ]
    
    var description: String {
        switch self {
            case .number: return "Number"
            case .yearFrom: return "Year"
            case .pieces: return "Pieces"
            case .minifigs: return "Minifigures"
            case .rating: return "Rating"
            case .retailPrice: return "Retail Price"
            case .theme: return "Theme"
            case .subtheme: return "Subtheme"
            case .name: return "Name"
            case .random: return "Random"
        }
    }
}

enum SortingDirection {
    case ascending
    case descending
    
    var description: String {
        switch self {
            case .ascending: return "Ascending"
            case .descending: return "Descending"
        }
    }

    var parameterValue: String {
        switch self {
            case .ascending: return ""
            case .descending: return "DESC"
        }
    }
}

struct SortingSelection {
    var sortingType: SortingType
    var direction: SortingDirection
    
    init(sortingType: SortingType = .yearFrom, direction: SortingDirection = .descending) {
        self.sortingType = sortingType
        self.direction = direction
    }

    var parameterValue: String {
        if sortingType == .retailPrice {
            return (Locale.current.regionCode ?? "US") + sortingType.rawValue + direction.parameterValue
        }
        else {
            return sortingType.rawValue + direction.parameterValue
        }
    }
}

public struct GetSetsRequest {
    
    var query: String?
    var theme: String?
    var subtheme: String?
    var year: String?
    var setNumber: String?
    var owned: Bool
    var wanted: Bool
    var sortingSelection: SortingSelection = SortingSelection()
    var grouping: GroupingType?

    init(query: String? = "", theme: String? = "", subtheme: String? = "", year: String? = "", setNumber: String? = "", owned: Bool = false, wanted: Bool = false) {
        self.query = query
        self.theme = theme
        self.subtheme = subtheme
        self.year = year
        self.setNumber = setNumber
        self.owned = owned
        self.wanted = wanted
    }
    
    init(filterOptions: FilterOptions) {
        self.query = filterOptions.searchTerm
        self.theme = filterOptions.selectedTheme?.name
        self.subtheme = filterOptions.selectedSubtheme?.name
        self.year = filterOptions.selectedYear?.name
        self.owned = filterOptions.filterOwned
        self.wanted = filterOptions.filterWanted
        self.sortingSelection = filterOptions.sortingSelection
        self.grouping = filterOptions.grouping
    }
    
}