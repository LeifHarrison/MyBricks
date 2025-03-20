//
//  UIStoryboard+Extensions.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/25/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    /// The uniform place where we state all the storyboard we have in our application
    
    enum Storyboard: String {
        case browse
        case mySets
        case news
        case profile
        case search
        case setDetail

        var filename: String {
            return rawValue.capitalized
        }
    }
    
    // MARK: - Convenience Initializers
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Class Functions
    // -------------------------------------------------------------------------

    class func storyboard(_ storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.filename, bundle: bundle)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - View Controller Instantiation from Generics
    // -------------------------------------------------------------------------

    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        
        return viewController
    }
    
}
