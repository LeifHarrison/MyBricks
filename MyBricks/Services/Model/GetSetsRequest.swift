//
//  GetSetsRequest.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/4/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

enum SortingType : String {
    case number = "Number"
    case yearFrom = "YearFrom"
    case pieces = "Pieces"
    case minifigs = "Minifigs"
    case rating = "Rating"
    case retailPriceUK = "UKRetailPrice"
    case retailPriceUS = "USRetailPrice"
    case retailPriceCA = "CARetailPrice"
    case retailPriceEU = "EURetailPrice"
    case theme = "Theme"
    case subtheme = "Subtheme"
    case name = "Name"
    case random = "Random"
    
    var description: String {
        switch self {
        case .number: return "Number"
        case .yearFrom: return "Year From"
        case .pieces: return "Pieces"
        case .minifigs: return "Minifigures"
        case .rating: return "Rating"
        case .retailPriceUK: return "Retail Price (UK)"
        case .retailPriceUS: return "Retail Price (US)"
        case .retailPriceCA: return "Retail Price (CA)"
        case .retailPriceEU: return "Retail Price (EU)"
        case .theme: return "Theme"
        case .subtheme: return "Subtheme"
        case .name: return "Name"
        case .random: return "Random"
        }
    }
}

enum SortingDirection : String {
    case ascending
    case descending
    
    var description: String {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
}

struct SortingSelection {
    var sortingType: SortingType = .number
    var direction: SortingDirection = .ascending
}

public struct GetSetsRequest {
    
    var query: String?
    var theme: String?
    var subtheme: String?
    var year: String?
    var setNumber: String?
    var owned: Bool
    var wanted: Bool
    
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
    }
}
