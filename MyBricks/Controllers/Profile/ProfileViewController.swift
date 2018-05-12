//
//  ProfileViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import KeychainAccess
import LocalAuthentication

class ProfileViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    enum TableSection: Int {
        case brickset
    }
    
    enum TableRow: Int {
        case profile
        case collection
    }
    
    var sections: [TableSection] = []
    var bricksetRows: [TableRow] = []

    var collectionTotals: UserCollectionTotals?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        instructionLabel.applyInstructionsStyle()
        loginButton.applyDefaultStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplay(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if BricksetServices.isLoggedIn() {
            updateCollectionInformation()
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func login(_ sender: AnyObject?) {
        if let protectionSpace = BricksetServices.shared.loginProtectionSpace, let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) {
            NSLog("Credential: \(credential), password: \(String(describing: credential.password))")
            evaluateBiometricAuthentication(credential: credential)
        }
        else {
            performSegue(withIdentifier: "showLoginView", sender: self)
        }
    }

    @IBAction func logout(_ sender: AnyObject?) {
        BricksetServices.logout()
        updateDisplay(animated: true)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.separatorColor = UIColor(white: 0.3, alpha: 0.8)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.tableFooterView = UIView()

        tableView.register(UINib(nibName:BricksetCollectionTableViewCell.nibName, bundle:nil), forCellReuseIdentifier: BricksetCollectionTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName:BricksetProfileTableViewCell.nibName, bundle:nil), forCellReuseIdentifier: BricksetProfileTableViewCell.reuseIdentifier)
    }
    
    fileprivate func updateDisplay(animated: Bool) {

        sections.removeAll()
        bricksetRows.removeAll()
        
        //let buttonItem = loggedIn ? UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout)) : nil
        //navigationItem.setRightBarButton(buttonItem, animated: animated)

        if BricksetServices.isLoggedIn() {
            transitionViews(fromView: loginView, toView: tableView, animated: animated)
            sections.append(.brickset)
            bricksetRows.append(.profile)
            tableView.reloadData()
        }
        else {
            transitionViews(fromView: tableView, toView: loginView, animated: animated)
        }
    }

    fileprivate func transitionViews(fromView: UIView, toView: UIView, animated: Bool = true) {
        toView.alpha = 0.0
        let fadeOutAnimations = { () -> Void in
            fromView.alpha = 0.0
        }
        let fadeOutCompletion = { (finished: Bool) -> Void in
            fromView.isHidden = true
            toView.isHidden = false
            let fadeInAnimations = { () -> Void in
                toView.alpha = 1.0
            }
            let fadeInCompletion = { (finished: Bool) -> Void in
            }
            UIView.animate(withDuration: animated ? 0.7 : 0, animations: fadeInAnimations, completion:fadeInCompletion)
        }
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: fadeOutAnimations, completion:fadeOutCompletion)
    }

    // MARK: - Updating Profile Information

    fileprivate func updateProfileInformation() {
        // TODO: Implement fetching Profile information once profile
        // service is available
    }

    // MARK: - Updating Collection Information

    fileprivate func updateCollectionInformation() {
        activityIndicator.startAnimating()
        BricksetServices.shared.getCollectionTotals(completion: { result in
            self.activityIndicator.stopAnimating()
            if result.isSuccess {
                self.collectionTotals = result.value
                self.bricksetRows.append(.collection)
                if let section = self.sections.index(of: .brickset), let row = self.bricksetRows.index(of: .collection) {
                    self.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .fade)
                }
            }
        })
    }
    
    fileprivate func evaluateBiometricAuthentication(credential: URLCredential) {
        let myContext = LAContext()
        let myLocalizedReasonString = "Login to your Brickset account"

        var authError: NSError?
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    // User authenticated successfully, take appropriate action
                    NSLog("Biometric authentication success!")
                    DispatchQueue.main.async {
                        self.performLogin(credential: credential)
                    }
                }
                else if let error = evaluateError as? LAError {
                    // User did not authenticate successfully, look at error and take appropriate action
                    NSLog("Biometric authentication error: \(String(describing: evaluateError))")
                    if error.code.rawValue == kLAErrorUserFallback {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showLoginView", sender: self)
                        }
                    }
                    else if error.code.rawValue == kLAErrorUserCancel {
                        return
                    }
                    else {
                        DispatchQueue.main.async {
                            self.displayLocalAuthenticationError(error: error)
                        }
                    }
                }
            }
        }
        else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            NSLog("Biometric authentication error: \(String(describing: authError))")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showLoginView", sender: self)
            }
        }
    }

    fileprivate func performLogin(credential: URLCredential) {
        if let username = credential.user, let password = credential.password {
            BricksetServices.shared.login(username: username, password: password, completion: { result in
                if result.isSuccess {
                    self.updateDisplay(animated: true)
                    self.updateProfileInformation()
                    self.updateCollectionInformation()
                }
                else {
                    let alert = UIAlertController(title: "Error", message: result.error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.performSegue(withIdentifier: "showLoginView", sender: self)
                }
            })
        }
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        if section == .brickset {
            return bricksetRows.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]

        if section == .brickset {
            let row = bricksetRows[indexPath.row]
            if row == .profile {
                if let cell = tableView.dequeueReusableCell(withIdentifier: BricksetProfileTableViewCell.reuseIdentifier, for: indexPath) as? BricksetProfileTableViewCell {
                    let keychain = Keychain(service: BricksetServices.serviceName)
                    if let username = UserDefaults.standard.value(forKey: "username") as? String, keychain[username] != nil {
                        cell.populateWith(username: username)
                    }
                    cell.logoutButtonTapped = {
                        BricksetServices.logout()
                        self.updateDisplay(animated: true)
                    }
                    return cell
                }
            }
            else if row == .collection {
                if let cell = tableView.dequeueReusableCell(withIdentifier: BricksetCollectionTableViewCell.reuseIdentifier, for: indexPath) as? BricksetCollectionTableViewCell {
                    cell.populateWithCollectionTotals(collectionTotals!)
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
