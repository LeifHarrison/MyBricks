//
//  Bundle+Extensions.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/15/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

extension Bundle {
    
    var appName: String {
        return (infoDictionary?["CFBundleName"] as? String) ?? "MyApp"
    }
    
    var bundleId: String {
        return bundleIdentifier!
    }
    
    var versionNumber: String {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }
    
    var buildNumber: String {
        return (infoDictionary?["CFBundleVersion"] as? String) ?? "0001"
    }
    
    var buildDate: String {
        return (infoDictionary?["BuildDate"] as? String) ?? ""
    }
    
    var gitVersion: String {
        return (infoDictionary?["GitVersion"] as? String) ?? ""
    }
    
}
