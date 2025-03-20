//
//  AppDelegate.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import AlamofireNetworkActivityIndicator
import AlamofireNetworkActivityLogger
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // -------------------------------------------------------------------------
    // MARK: - UIApplicationDelegate
    // -------------------------------------------------------------------------
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        NetworkActivityIndicatorManager.shared.isEnabled = true
        
#if DEBUG
        configureLogging()
#endif

        validateAPIKey() // Validate that our BrickSet API Key is still valid

        styleNavigationBar()
        styleTabBar()

        return true
    }

    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------
    
    private func configureLogging() {
        // Don't log image URL requests
        let imagePredicate = NSPredicate { (object, _) in
            if let request = object as? NSURLRequest, let url = request.url {
                return url.lastPathComponent.hasSuffix(".jpg")
            }
            return false
        }
        NetworkActivityLogger.shared.filterPredicate = imagePredicate
        // Set level to 'debug' to get complete request/response detail
        // NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
    }
    
    private func validateAPIKey() {
        BricksetServices.shared.checkKey(completion: { result in
            switch result {
                case let .success(isValid):
                    if !isValid {
                        let message = NSLocalizedString(
                            "It looks like the BrickSet API key is no longer valid. Please update the application or notify the developer.",
                            comment: "")
                        let alert = UIAlertController(title: "Invalid Key", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }

                case let .failure(error):
                    NSLog("Error validating API Key: \(error.localizedDescription)")
            }
            self.validateUserHash()
        })
    }

    private func validateUserHash() {
        if BricksetServices.isLoggedIn() {
            BricksetServices.shared.checkUserHash(completion: { result in
                switch result {
                    case let .success(isValid):
                        if !isValid {
                            let message = NSLocalizedString("It looks like the userHash is no longer valid.", comment: "")
                            let alert = UIAlertController(title: "Invalid Key", message: message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        }

                    case let .failure(error):
                        NSLog("Error validating user hash: \(error.localizedDescription)")
                }
            })
        }
    }
    
    private let navigationBarHeight: CGFloat = 44.0
    private let statusBarHeight: CGFloat = 44.0

    private func styleNavigationBar() {
        
        // Figure out navigation bar size
        let screenHeight = UIScreen.main.bounds.size.height // Use the height rather than width to support landscape rotation
        var barHeight = navigationBarHeight
        if let window = window {
            barHeight += window.safeAreaInsets.top
            if window.safeAreaInsets.top == 0 {
                barHeight += statusBarHeight
            }
        }
        
        // Generate gradient image
        let image = gradientImage(withSize: CGSize(width: screenHeight, height: barHeight)) // 88 on iPhone X

        UINavigationBar.appearance().setBackgroundImage(image, for: .default)
        UINavigationBar.appearance().tintColor = UIColor.lightNavy
        
        let attributes: [NSAttributedString.Key: AnyObject] = [ .font : UIFont.boldSystemFont(ofSize: 18), .foregroundColor : UIColor.lightNavy ]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
    
    private let tabBarHeight: CGFloat = 49.0

    private func styleTabBar() {
        
        // Figure out tab bar size
        let screenHeight = UIScreen.main.bounds.size.height  // Use the height rather than width to support landscape rotation
        var barHeight = tabBarHeight
        if let window = window {
            barHeight += window.safeAreaInsets.bottom
        }
        
        // Generate gradient image
        let image = gradientImage(withSize: CGSize(width: screenHeight, height: barHeight))

        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundImage = image
            
            setTabBarItemColors(tabBarAppearance.stackedLayoutAppearance)
            setTabBarItemColors(tabBarAppearance.inlineLayoutAppearance)
            setTabBarItemColors(tabBarAppearance.compactInlineLayoutAppearance)

            UITabBar.appearance().standardAppearance = tabBarAppearance
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }

        }
        
    }
    
    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.normal.iconColor = .cloudyBlue
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.cloudyBlue]
        
        itemAppearance.selected.iconColor = .lightNavy
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightNavy]
    }

    private func gradientImage(withSize size: CGSize) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradient.colors = [UIColor.almostWhite.cgColor, UIColor.paleGrey.cgColor]
        let image = self.image(fromLayer: gradient)
        return image
    }
    
    private func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }

}
