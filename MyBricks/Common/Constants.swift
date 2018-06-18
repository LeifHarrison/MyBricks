//
//  Constants.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/11/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import Foundation

// swiftlint:disable nesting

struct Constants {
    
    struct Brickset {
        static let url = "https://brickset.com"
        static let apiKey = "<brickset-api-key>"
    }
    
    struct Rebrickable {
        static let url = "https://rebrickable.com"
        static let apiKey = "<rebrickable-api-key>"
    }
    
    struct GoogleMobileAds {
        static let appId = "<admob-app-id>"
        
        struct AdUnits {
#if DEBUG
            static let browseThemes = "ca-app-pub-3940256099942544/2934735716" // Test Banner Ad ID
#else
            static let browseThemes = "<admob-banner-id>" // Production Banner Ad ID
#endif
        }
        
    }
    
    struct Alamofire {
        static let url = "https://github.com/Alamofire/Alamofire"
    }
    struct AlamofireImage {
        static let url = "https://github.com/Alamofire/AlamofireImage"
    }
    struct AlamofireRSSParser {
        static let url = "https://github.com/AdeptusAstartes/AlamofireRSSParser"
    }
    struct Cosmos {
        static let url = "https://github.com/evgenyneu/Cosmos"
    }
    struct Fuzi {
        static let url = "https://github.com/cezheng/Fuzi"
    }
    struct KeychainAccess {
        static let url = "https://github.com/kishikawakatsumi/KeychainAccess"
    }

}

// swiftlint:enable nesting
