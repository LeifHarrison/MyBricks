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

    @IBOutlet weak var tableView: UITableView!

    enum TableSection: Int {
        case brickset
        case rebrickable
        case general
    }
    
    enum TableRow: Int {
        case profile
        case collection
    }

    enum GeneralTableRow: Int {
        case about
        case credits
        case donate
        case legal

        var title: String {
            switch self {
            case .about: return NSLocalizedString("About", comment: "")
            case .credits: return NSLocalizedString("Credits", comment: "")
            case .donate: return NSLocalizedString("Donate", comment: "")
            case .legal: return NSLocalizedString("Legal", comment: "")
            }
        }

    }
    
    var sections: [TableSection] = []
    var bricksetRows: [TableRow] = []
    var rebrickableRows: [TableRow] = []
    var generalRows: [GeneralTableRow] = []

    var collectionTotals: UserCollectionTotals?

    private let lastUpdatedKey = "collectionLastUpdated"
    private let updateInterval: TimeInterval = 5 * 60 // Only refresh every 5 minutes
    private let spacerHeight: CGFloat = 5
    
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
//        if RebrickableServices.isLoggedIn() {
//            updateProfileInformation()
//        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func setupTableView() {
        
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionFooterHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()

        tableView.register(ProfileLoginTableViewCell.self)
        tableView.register(BricksetCollectionTableViewCell.self)
        tableView.register(ProfileGeneralTableViewCell.self)
    }
    
    fileprivate func updateDisplayedRows() {

        sections.removeAll()
        bricksetRows.removeAll()
        rebrickableRows.removeAll()
        generalRows.removeAll()

        sections.append(.brickset)
        bricksetRows.append(.profile)
        if BricksetServices.isLoggedIn() {
            bricksetRows.append(.collection)
        }

//        sections.append(.rebrickable)
//        rebrickableRows.append(.profile)
//        if BricksetServices.isLoggedIn() {
//            rebrickableRows.append(.collection)
//        }
        
        sections.append(.general)
        generalRows.append(.about)
        generalRows.append(.credits)
        generalRows.append(.donate)
        generalRows.append(.legal)
        tableView.reloadData()
    }

    private func loginToBrickset() {
        if hasDefaultCredentials(for: BricksetServices.shared) {
            evaluateBiometricAuthentication(for: BricksetServices.shared)
        }
        else {
            if let loginVC: ProfileLoginViewController = storyboard?.instantiateViewController() {
                loginVC.serviceAPI = BricksetServices.shared
                present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    private func loginToRebrickable() {
        if hasDefaultCredentials(for: RebrickableServices.shared) {
            evaluateBiometricAuthentication(for: RebrickableServices.shared)
        }
        else {
            if let loginVC: ProfileLoginViewController = storyboard?.instantiateViewController() {
                loginVC.serviceAPI = RebrickableServices.shared
                present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Updating Profile Information

    fileprivate func updateProfileInformation() {
        // TODO: Implement fetching Profile information once profile
        // service is available
//        RebrickableServices.shared.getProfile(completion: { result in
//            if result.isSuccess, let profile = result.value {
//                NSLog("Result: \(profile)")
//            }
//            else {
//                NSLog("Error updating profile: \(String(describing: result.error))")
//            }
//        })
    }

    // MARK: - Updating Collection Information

    fileprivate func updateCollectionInformation() {
        BricksetServices.shared.getCollectionTotals(completion: { result in
            if result.isSuccess {
                UserDefaults.standard.set(Date(), forKey: self.lastUpdatedKey)
                self.collectionTotals = result.value
                if let section = self.sections.index(of: .brickset), let row = self.bricksetRows.index(of: .collection) {
                    let indexPath = IndexPath(row: row, section: section)
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        })
    }
    
    fileprivate func hasDefaultCredentials(for serviceAPI: AuthenticatedServiceAPI) -> Bool {
        if let protectionSpace = serviceAPI.loginProtectionSpace {
            NSLog("protectionSpace = \(protectionSpace)")
            if URLCredentialStorage.shared.defaultCredential(for: protectionSpace) != nil {
                return true
            }
        }
        return false
    }
    
    fileprivate func evaluateBiometricAuthentication(for serviceAPI: AuthenticatedServiceAPI) {
        guard let protectionSpace = serviceAPI.loginProtectionSpace, let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) else {
            return
        }
        
        let myContext = LAContext()
        let myLocalizedReasonString = "Login to your Brickset account"

        var authError: NSError?
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    // User authenticated successfully, take appropriate action
                    DispatchQueue.main.async {
                        self.performLogin(service: serviceAPI, credential: credential)
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

    fileprivate func performLogin(service: AuthenticatedServiceAPI, credential: URLCredential) {
        if let username = credential.user, let password = credential.password {
            service.login(username: username, password: password, completion: { result in
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
        else if section == .rebrickable {
            return rebrickableRows.count
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
                let cell: ProfileLoginTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populate(for: BricksetServices.shared)
                if BricksetServices.isLoggedIn() {
                    cell.loginButtonTapped = {
                        let completion = {
                            tableView.reloadRows(at: [indexPath], with: .fade)
                            if let section = self.sections.index(of: .brickset), let row = self.bricksetRows.index(of: .collection) {
                                self.bricksetRows.remove(at: row)
                                self.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .fade)
                            }
                        }
                        BricksetServices.shared.logout(completion)
                    }
                    cell.signupButtonTapped = nil
                }
                else {
                    cell.loginButtonTapped = {
                        self.loginToBrickset()
                    }
                    cell.signupButtonTapped = {
                        if let url = URL(string: Constants.Brickset.signupURL) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                return cell
            }
            else if row == .collection {
                let cell: BricksetCollectionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populateWithCollectionTotals(collectionTotals)
                return cell
            }
        }
        if section == .rebrickable {
            let row = rebrickableRows[indexPath.row]
            if row == .profile {
                let cell: ProfileLoginTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populate(for: RebrickableServices.shared)
                if RebrickableServices.isLoggedIn() {
                    cell.loginButtonTapped = {
                        let completion = {
                            if let section = self.sections.index(of: .rebrickable), let row = self.rebrickableRows.index(of: .collection) {
                                self.rebrickableRows.remove(at: row)
                                self.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .fade)
                            }
                            tableView.reloadRows(at: [indexPath], with: .fade)
                        }
                        RebrickableServices.shared.logout(completion)
                    }
                    cell.signupButtonTapped = nil
                }
                else {
                    cell.loginButtonTapped = {
                        self.loginToRebrickable()
                    }
                    cell.signupButtonTapped = {
                        if let url = URL(string: Constants.Brickset.signupURL) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                return cell
            }
            else if row == .collection {
                let cell: BricksetCollectionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populateWithCollectionTotals(collectionTotals)
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
            case .credits:
                performSegue(withIdentifier: "showCreditsView", sender: self)
            case .donate:
                performSegue(withIdentifier: "showDonateView", sender: self)
            case .legal:
                performSegue(withIdentifier: "showLegalView", sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (sections.count - 1) {
            return spacerHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return spacerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
}
