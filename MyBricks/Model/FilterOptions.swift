//
//  FilterOptions.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 1/29/18.
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
    
    var showOwned: Bool = false
    var showWanted: Bool = false
    
}

