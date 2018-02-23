//
//  BrowseSetsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage

class BrowseSetsViewController: UIViewController {

    @IBOutlet weak var headerView: BrowseHeaderView!
    @IBOutlet weak var tableView: UITableView!

    var filterOptions: FilterOptions = FilterOptions()
    var showUnreleased: Bool = false
    var browseRequest: Request? = nil
    
    var allSets: [Set] = []
    var sectionTitles: [String] = []
    var setsBySection: [String : [Set]] = [:]
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName:SetListTableViewCell.nibName, bundle:nil), forCellReuseIdentifier: SetListTableViewCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if filterOptions.searchTerm != nil {
            self.title = "Search Results"
        }
        else if let theme = filterOptions.selectedTheme {
            self.title = theme.name
        }
        else {
            self.title = "Browse Sets"
        }
        
        updateDisplay(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if allSets.count == 0 && (!filterOptions.showingUserSets || BricksetServices.isLoggedIn()) {
            fetchSets()
        }
        else if browseRequest == nil {
            processSets()
            updateDisplay(animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let request = self.browseRequest {
            request.cancel()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func showFilters(_ sender: UIBarButtonItem) {
        let filterStoryboard = UIStoryboard(name: "Filter", bundle: nil)
        if let filterVC = filterStoryboard.instantiateInitialViewController() as? FilterViewController {
            filterVC.delegate = self
            filterVC.filterOptions = self.filterOptions
            
            let navController = UINavigationController(rootViewController: filterVC)
            show(navController, sender: self)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func fetchSets() {
        SimpleActivityHUD.show(overView: view)
        let request = GetSetsRequest(filterOptions: self.filterOptions)
        self.browseRequest = BricksetServices.shared.getSets(request, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            SimpleActivityHUD.hide()
            if result.isSuccess {
                strongSelf.allSets = result.value ?? []
                strongSelf.processSets()
                strongSelf.updateDisplay(animated: true)
            }
            else {
                if let error = result.error as? URLError, error.code == .cancelled { return }
                else if let error = result.error {
                    print("Error loading sets: \(error)")
                }
            }
        })
    }
    
    fileprivate func processSets() {
        sectionTitles.removeAll()
        setsBySection.removeAll()

        // Have to filter for "Not Owned" ourselves
        if filterOptions.filterNotOwned {
            allSets = allSets.filter {
                if let owned = $0.owned {
                    return !owned
                }
                return true
            }
        }

        for set in allSets {
            // By default, don't show unreleased sets
            if let released = set.released, released != true && !showUnreleased {
                continue
            }
            if let year = set.year {
                let indexName = String(year)
                var sets: [Set] = setsBySection[indexName] ?? []
                sets.append(set)
                setsBySection[indexName] = sets
            }
        }
        sectionTitles = setsBySection.keys.sorted(by: >)
    }

    fileprivate func showTableView(faded: Bool) {
        let animations = { () -> Void in
            self.tableView.alpha = faded ? 0.3 : 1.0
        }
        UIView.animate(withDuration: 0.2, animations:animations)
    }

    internal func updateDisplay(animated: Bool = false) {
        
        if self.allSets.count > 0 {
            let item = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilters(_:)))
            navigationItem.setRightBarButton(item, animated: animated)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: animated)
        }

        let animations = { () -> Void in
            self.headerView.alpha = 0.0
            self.tableView.alpha = 0.0
        }
        let completion = { (finished: Bool) -> Void in
            
            if self.allSets.count > 0 {
                self.headerView.populate(with: self.allSets.count, filterOptions: self.filterOptions)
                self.tableView.contentInset = UIEdgeInsets(top: self.headerView.frame.height, left: 0, bottom: 0, right: 0)
                self.tableView.reloadData()
                let innerAnimations = { () -> Void in
                    self.headerView.alpha = 1.0
                    self.tableView.alpha = 1.0
                }
                UIView.animate(withDuration: animated ? 0.3 : 0.0, animations:innerAnimations)
            }
            else {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations:animations, completion: completion)
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension BrowseSetsViewController: UITableViewDataSource {

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

extension BrowseSetsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = sectionTitles[indexPath.section]
        if let sets = setsBySection[sectionTitle] {
            let set = sets[indexPath.row]
            let detailStoryboard = UIStoryboard(name: "SetDetail", bundle: nil)
            if let detailVC = detailStoryboard.instantiateInitialViewController() as? SetDetailViewController {
                detailVC.currentSet = set
                show(detailVC, sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

}

//==============================================================================
// MARK: - FilterViewControllerDelegate
//==============================================================================

extension BrowseSetsViewController: FilterViewControllerDelegate {
    
    func filterViewController(_ controller: FilterViewController, didUpdateFilterOptions filterOptions: FilterOptions) {
        self.filterOptions = filterOptions
        fetchSets()
    }
    
}

