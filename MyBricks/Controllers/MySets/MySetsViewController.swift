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
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!

    var mySetsRequest: Request?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        instructionLabel.applyInstructionsStyle()
        loginButton.applyDefaultStyle()
        signupLabel.applyInstructionsStyle()

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
                if result {
                    self.updateDisplay()
                }
            })
        }
        else {
            showLoginView()
        }
    }

    @IBAction func goToBrickset(_ sender: AnyObject?) {
        if let url = URL(string: Constants.Brickset.signupURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else {
            headerView.isHidden = true
            tableView.isHidden = true
            loginView.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
}
