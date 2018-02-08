//
//  MySetsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import Alamofire

class MySetsViewController: UIViewController {

    enum DisplayMode: Int {
        case owned
        case wanted
    }
    
    enum GroupingMode: Int {
        case year
        case theme
    }
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var headerView: MySetsHeaderView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var mySetsRequest: Request? = nil

    var allSets: [Set] = []
    var sectionTitles: [String] = []
    var setsBySection: [String : [Set]] = [:]

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        loginButton.layer.cornerRadius = 5.0
        
        tableView.register(UINib(nibName:SetListTableViewCell.nibName, bundle:nil), forCellReuseIdentifier: SetListTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if BricksetServices.isLoggedIn() {
            updateSets()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let request = self.mySetsRequest {
            request.cancel()
        }
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
                    self.updateSets()
                }
            })
        }
        else {
            showLoginView()
        }
    }

    @IBAction func toggleSetsShown(_ sender: AnyObject?) {
        let fadeOut = { () -> Void in
            self.headerView.showButtonContainer.alpha = 0.0
        }
        let completion: ((Bool) -> Void) = { (Bool) -> Void in
            self.displayMode = (self.displayMode == .owned) ? .wanted : .owned

            let fadeIn = { () -> Void in
                self.headerView.showButtonContainer.alpha = 1.0
            }
            UIView.animate(withDuration: 0.1, animations:fadeIn)

        }
        UIView.animate(withDuration: 0.1, animations:fadeOut, completion: completion)

    }

    @IBAction func toggleGrouping(_ sender: AnyObject?) {
        self.groupingMode = (self.groupingMode == .year) ? .theme : .year
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    var displayMode: DisplayMode = .owned {
        didSet {
            headerView.showButton.setTitle( displayMode == .owned ? "OWNED" : "WANTED", for: .normal)
            updateSets()
        }
    }

    var groupingMode: GroupingMode = .year {
        didSet {
            headerView.groupButton.setTitle( groupingMode == .year ? "YEAR" : "THEME", for: .normal)
            processSets()
            self.tableView.reloadData()
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func updateDisplay() {
        if BricksetServices.isLoggedIn() {
            headerView.isHidden = false
            tableView.isHidden = false
            loginView.isHidden = true

            headerView.showButton.setTitle( displayMode == .owned ? "OWNED" : "WANTED", for: .normal)
            headerView.groupButton.setTitle( groupingMode == .year ? "YEAR" : "THEME", for: .normal)
        }
        else {
            headerView.isHidden = true
            tableView.isHidden = true
            loginView.isHidden = false
        }
    }

    private func updateSets() {

        if let request = self.mySetsRequest {
            request.cancel()
        }
        
        let fadeOut = { () -> Void in
            self.tableView.alpha = 0.4
        }
        UIView.animate(withDuration: 0.1, animations:fadeOut)

        activityIndicator?.startAnimating()
        let request = GetSetsRequest(owned: (displayMode == .owned), wanted: (displayMode == .wanted))
        self.mySetsRequest = BricksetServices.shared.getSets(request, completion: { result in
            self.activityIndicator?.stopAnimating()

            if result.isSuccess {
                self.allSets = result.value ?? []
                self.processSets()
                
                self.tableView.reloadData()
                let fadeIn = { () -> Void in
                    self.tableView.alpha = 1.0
                }
                UIView.animate(withDuration: 0.2, animations:fadeIn)
            }
            else {
                if let error = result.error as? URLError, error.code == .cancelled { return }
                else if let error = result.error {
                    print("Error loading sets: \(error)")
                }
            }
        })
    }

    private func processSets() {
        sectionTitles.removeAll()
        setsBySection.removeAll()

        for set in allSets {
            var indexName = "All"
            if groupingMode == .year, let year = set.year {
                indexName = String(year)
            }
            else if groupingMode == .theme, let theme = set.theme {
                indexName = theme
            }

            var sets: [Set] = setsBySection[indexName] ?? []
            sets.append(set)
            setsBySection[indexName] = sets
        }

        if groupingMode == .year {
            sectionTitles = setsBySection.keys.sorted(by: >)
        }
        else if groupingMode == .theme {
            sectionTitles = setsBySection.keys.sorted(by: <)
        }
    }

}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension MySetsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        if let sets = setsBySection[sectionTitle] {
            return sets.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionTitle = sectionTitles[indexPath.section]
        if let sets = setsBySection[sectionTitle] {
            let set = sets[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: SetListTableViewCell.reuseIdentifier, for: indexPath) as? SetListTableViewCell {
                cell.populateWithSet(set)
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension MySetsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = sectionTitles[indexPath.section]
        if let sets = setsBySection[sectionTitle] {
            let browseStoryboard = UIStoryboard(name: "Browse", bundle: nil)
            let set = sets[indexPath.row]
            if let setDetailVC = browseStoryboard.instantiateViewController(withIdentifier: "SetDetailViewController") as? SetDetailViewController {
                setDetailVC.currentSet = set
                show(setDetailVC, sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

