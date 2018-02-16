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

    //--------------------------------------------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------------------------------------------
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        configureLogging()
        validateAPIKey() // Validate that our BrickSet API Key is still valid

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
    
    private func configureLogging() -> Void {
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
    
    private func validateAPIKey() -> Void {
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

    private func validateUserHash() -> Void {
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
}

