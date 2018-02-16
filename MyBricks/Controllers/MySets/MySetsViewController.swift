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

        loginButton.layer.cornerRadius = 5.0
        
        filterOptions = FilterOptions()
        filterOptions?.filterOwned = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "My Sets"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func login(_ sender: AnyObject?) {
        if let protectionSpace = BricksetServices.shared.loginProtectionSpace, let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) {
            print("Credential: \(credential), password: \(String(describing: credential.password))")
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

    private func updateDisplay() {
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

