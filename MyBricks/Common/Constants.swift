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
        static let signupURL = "https://brickset.com/signup"
        static let apiKey = "PJ6U-J8Ob-GG1k"
    }
    
    struct Rebrickable {
        static let url = "https://rebrickable.com"
        static let apiKey = "7ee6c70b29646296c7d4778cabb4d476"
    }
    
    struct GoogleMobileAds {
        static let appId = "ca-app-pub-2158913963073917~7545030919"
        
        struct AdUnits {
#if DEBUG
            static let browseThemes = "ca-app-pub-3940256099942544/2934735716" // Test Banner Ad ID
#else
            static let browseThemes = "ca-app-pub-2158913963073917/8970503662" // Production Banner Ad ID
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
    struct KeychainAccess {
        static let url = "https://github.com/kishikawakatsumi/KeychainAccess"
    }

}

// swiftlint:enable nesting
