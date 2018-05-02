//
//  MySetsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import Alamofire

class MySetsViewController: BrowseSetsViewController {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    var mySetsRequest: Request? = nil

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        instructionLabel.applyInstructionsStyle()
        loginButton.applyDefaultStyle()

        filterOptions.showingUserSets = true
        filterOptions.filterOwned = true
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func login(_ sender: AnyObject?) {
        if let protectionSpace = BricksetServices.shared.loginProtectionSpace, let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) {
            NSLog("Credential: \(credential), password: \(String(describing: credential.password))")
            evaluateBiometricAuthentication(credential: credential, completion: { (result) in
                self.updateDisplay()
                if BricksetServices.isLoggedIn() {
                    //self.updateSets()
                }
            })
        }
        else {
            showLoginView()
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    override func updateDisplay(animated: Bool = false) {
        super.updateDisplay(animated: animated)
        if BricksetServices.isLoggedIn() {
            headerView.isHidden = false
            tableView.isHidden = false
            loginView.isHidden = true
        }
        else {
            headerView.isHidden = true
            tableView.isHidden = true
            loginView.isHidden = false
        }
    }
    
}

