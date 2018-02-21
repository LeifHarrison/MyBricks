//
//  GetSetsRequest.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/4/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

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
