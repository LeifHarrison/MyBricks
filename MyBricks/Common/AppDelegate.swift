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
import GoogleMobileAds
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //--------------------------------------------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------------------------------------------
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: Constants.GoogleMobileAds.appId)

        NetworkActivityIndicatorManager.shared.isEnabled = true
        
#if DEBUG
        configureLogging()
#endif

        validateAPIKey() // Validate that our BrickSet API Key is still valid

        styleNavigationBar()
        styleTabBar()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func configureLogging() {
        // Don't log image URL requests
        let imagePredicate = NSPredicate { (object, _) in
            if let request = object as? NSURLRequest, let url = request.url {
                return url.lastPathComponent.hasSuffix(".jpg")
            }
            return false
        }
        NetworkActivityLogger.shared.filterPredicate = imagePredicate
        NetworkActivityLogger.shared.startLogging()
    }
    
    private func validateAPIKey() {
        BricksetServices.shared.checkKey(completion: { result in
            if let valid = result.value, valid != true {
                let message = NSLocalizedString("It looks like the BrickSet API key is no longer valid. Please update the application or notify the developer.", comment: "")
                let alert = UIAlertController(title: "Invalid Key", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            self.validateUserHash()
        })
    }

    private func validateUserHash() {
        if BricksetServices.isLoggedIn() {
            BricksetServices.shared.checkUserHash(completion: { result in
                if let valid = result.value, valid != true {
                    let message = NSLocalizedString("It looks like the userHash is no longer valid.", comment: "")
                    let alert = UIAlertController(title: "Invalid Key", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
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
        
        let attributes: [NSAttributedStringKey: AnyObject] = [ .font : UIFont.boldSystemFont(ofSize: 18), .foregroundColor : UIColor.lightNavy ]
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

        UITabBar.appearance().backgroundImage = image
        UITabBar.appearance().tintColor = UIColor.lightNavy
        UITabBar.appearance().unselectedItemTintColor = UIColor.cloudyBlue
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
