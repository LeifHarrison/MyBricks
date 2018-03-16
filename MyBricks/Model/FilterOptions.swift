//
//  FilterOptions.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

enum GroupingType {
    case theme
    case subtheme
    case year

    var description: String {
        switch self {
            case .theme: return "Theme"
            case .subtheme: return "Subtheme"
            case .year: return "Year"
        }
    }
}


struct FilterOptions {
    
    var showingUserSets: Bool = false
    var initialTheme: SetTheme? = nil

    var searchType: SearchType? = nil
    var searchTerm: String? = nil
    
    var availableThemes: [SetTheme] = []
    var selectedTheme: SetTheme? = nil

    var availableSubthemes: [SetSubtheme] = []
    var selectedSubtheme: SetSubtheme? = nil
    
    var availableYears: [SetYear] = []
    var selectedYear: SetYear? = nil
    
    var filterOwned: Bool = false
    var filterNotOwned: Bool = false
    var filterWanted: Bool = false
    
    var showUnreleased: Bool = false

    var sortingSelection: SortingSelection = SortingSelection()
    var grouping: GroupingType? = nil
    
    public func hasSelectedFilters() -> Bool {
        return searchTerm != nil || (showingUserSets && selectedTheme != nil ) || selectedSubtheme != nil || selectedYear != nil || filterOwned || filterNotOwned || filterWanted
    }
}

