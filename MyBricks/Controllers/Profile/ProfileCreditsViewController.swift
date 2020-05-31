//
//  ProfileCreditsViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/31/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class ProfileCreditsViewController: UIViewController {

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func goToBrickset(_ sender: AnyObject?) {
        if let url = URL(string: Constants.Brickset.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func goToRebrickable(_ sender: AnyObject?) {
        if let url = URL(string: Constants.Rebrickable.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func goToAlamofire(_ sender: AnyObject?) {
        if let url = URL(string: Constants.Alamofire.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func goToAlamofireImage(_ sender: AnyObject?) {
        if let url = URL(string: Constants.AlamofireImage.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func goToAlamofireRSSParser(_ sender: AnyObject?) {
        if let url = URL(string: Constants.AlamofireRSSParser.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func goToCosmos(_ sender: AnyObject?) {
        if let url = URL(string: Constants.Cosmos.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func goToKeychainAccess(_ sender: AnyObject?) {
        if let url = URL(string: Constants.KeychainAccess.url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
