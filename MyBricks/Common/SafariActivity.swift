//
//  SafariActivity.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/7/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SafariActivity: UIActivity {
    
    public var URL: URL?
    
    public override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "SafariActivity")
    }
    
    public override var activityTitle: String? {
        return Bundle.main.localizedString(forKey: "Open in Safari", value: "Open in Safari", table: nil)
    }
    
    public override var activityImage: UIImage? {
        return UIImage(named: "safari")
    }
    
    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        var canPerform = false
        
        for activityItem in activityItems {
            if let URL = activityItem as? URL {
                if UIApplication.shared.canOpenURL(URL) {
                    canPerform = true
                    break
                }
            }
        }
        
        return canPerform
    }
    
    public override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if let URL = activityItem as? URL {
                self.URL = URL
                break
            }
        }
    }
    
    public override func perform() {
        if let URL = URL, UIApplication.shared.canOpenURL(URL) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            activityDidFinish(true)
        }
        
        activityDidFinish(false)
    }
    
}
