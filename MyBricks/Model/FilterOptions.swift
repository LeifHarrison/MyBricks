//
//  FilterOptions.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

public struct FilterOptions {
    
    var availableThemes: [SetTheme] = []
    var availableSubthemes: [SetSubtheme] = []
    var availableYears: [SetYear] = []
    
    var selectedTheme: SetTheme? = nil
    var selectedSubtheme: SetSubtheme? = nil
    var selectedYear: SetYear? = nil
    
    var filterOwned: Bool = false
    var filterNotOwned: Bool = false
    var filterWanted: Bool = false
    
    public func hasSelectedFilters() -> Bool {
        return selectedSubtheme != nil || selectedYear != nil || filterOwned || filterNotOwned || filterWanted
    }
}

