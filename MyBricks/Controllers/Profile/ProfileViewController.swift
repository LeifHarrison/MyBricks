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

    enum TableSection: Int {
        case brickset
        case general
    }
    
    enum TableRow: Int {
        case profile
        case collection
    }

    enum GeneralTableRow: Int {
        case about
        case acknowledgements
        case donate
        
        var title: String {
            switch self {
            case .about: return NSLocalizedString("About", comment: "")
            case .acknowledgements: return NSLocalizedString("Acknowledgments", comment: "")
            case .donate: return NSLocalizedString("Donate", comment: "")
            }
        }

    }
    
    var sections: [TableSection] = []
    var bricksetRows: [TableRow] = []
    var generalRows: [GeneralTableRow] = []

    var collectionTotals: UserCollectionTotals?

    private let lastUpdatedKey = "collectionLastUpdated"
    private let updateInterval: TimeInterval = 5 * 60 // Only refresh every 5 minutes

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayedRows()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let lastUpdated = UserDefaults.standard.value(forKey: lastUpdatedKey) as? Date ?? Date.distantPast
        if BricksetServices.isLoggedIn() && (collectionTotals == nil || Date().timeIntervalSince(lastUpdated) > updateInterval) {
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
        updateDisplayedRows()
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()

        tableView.register(BricksetCollectionTableViewCell.self)
        tableView.register(BricksetProfileTableViewCell.self)
        tableView.register(ProfileGeneralTableViewCell.self)
    }
    
    fileprivate func updateDisplayedRows() {

        sections.removeAll()
        bricksetRows.removeAll()
        generalRows.removeAll()

        //let buttonItem = loggedIn ? UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout)) : nil
        //navigationItem.setRightBarButton(buttonItem, animated: animated)

        sections.append(.brickset)
        bricksetRows.append(.profile)
        if collectionTotals != nil {
            bricksetRows.append(.collection)
        }

        sections.append(.general)
        generalRows.append(.about)
        generalRows.append(.acknowledgements)
        generalRows.append(.donate)
        tableView.reloadData()
    }

    private let regularAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.black]
    private let boldAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.black]
    
    private func loggedInAsAttributedDescription(forUsername username: String) -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You are logged in as ", attributes: regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(username)", attributes: boldAttributes))
        return attributedDescription
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
                UserDefaults.standard.set(Date(), forKey: self.lastUpdatedKey)
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
                    self.updateDisplayedRows()
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
        else if section == .general {
            return generalRows.count
        }
            
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]

        if section == .brickset {
            let row = bricksetRows[indexPath.row]
            if row == .profile {
                let cell: BricksetProfileTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                if BricksetServices.isLoggedIn() {
                    let keychain = Keychain(service: BricksetServices.serviceName)
                    if let username = UserDefaults.standard.value(forKey: "username") as? String, keychain[username] != nil {
                        cell.statusLabel.attributedText = self.loggedInAsAttributedDescription(forUsername: username)
                        cell.loginButton.setTitle("LOGOUT", for: .normal)
                    }
                    cell.loginButtonTapped = {
                        BricksetServices.logout()
                        tableView.reloadRows(at: [indexPath], with: .fade)
                        if let section = self.sections.index(of: .brickset), let row = self.bricksetRows.index(of: .collection) {
                            self.bricksetRows.remove(at: row)
                            self.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .fade)
                        }
                    }
                }
                else {
                    cell.statusLabel.text = NSLocalizedString("profile.login.helptext", comment:"")
                    cell.statusLabel.applyInstructionsStyle()
                    cell.loginButton.setTitle("LOGIN", for: .normal)
                    cell.loginButtonTapped = {
                        self.login(self)
                    }
                }
                return cell
            }
            else if row == .collection {
                let cell: BricksetCollectionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populateWithCollectionTotals(collectionTotals!)
                return cell
            }
        }
        else if section == .general {
            let cell: ProfileGeneralTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            let row = generalRows[indexPath.row]
            cell.titleLabel.text = row.title
            return cell
        }
        
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        if section == .general {
            let row = generalRows[indexPath.row]
            switch row {
                case .about:
                    performSegue(withIdentifier: "showAboutView", sender: self)
                case .acknowledgements:
                    performSegue(withIdentifier: "showCreditsView", sender: self)
                case .donate:
                    performSegue(withIdentifier: "showDonateView", sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let clearSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 5))
        clearSpacerView.backgroundColor = UIColor.clear
        return clearSpacerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (sections.count - 1) {
            return 5
        }
        return 5
    }
    
}
