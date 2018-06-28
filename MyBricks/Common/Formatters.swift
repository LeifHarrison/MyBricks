//
//  Formatters.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/26/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

struct Formatters {
    
    static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let mediumDateShortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let fileSizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        return formatter
    }()
    
}
