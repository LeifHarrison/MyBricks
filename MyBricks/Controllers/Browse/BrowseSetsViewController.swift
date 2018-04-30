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
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(SetListTableViewCell.self)
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
                    NSLog("Error loading sets: \(error)")
                }
            }
        })
    }
    
    fileprivate func processSets() {
        sectionTitles.removeAll()
        setsBySection.removeAll()

        // Have to filter for "Not Owned" ourselves
        if filterOptions.filterNotOwned {
            allSets = allSets.filter { return !$0.owned }
        }

        for set in allSets {
            if !set.released && !filterOptions.showUnreleased {
                continue
            }
            
            var indexName = ""
            if let grouping = filterOptions.grouping {
                if grouping == .theme, let theme = set.theme {
                    indexName = String(theme)
                }
                if grouping == .subtheme, let subtheme = set.subtheme {
                    indexName = String(subtheme)
                }
                if grouping == .year, let year = set.year {
                    indexName = String(year)
                }

            }
            
            var sets: [Set] = setsBySection[indexName] ?? []
            sets.append(set)
            setsBySection[indexName] = sets
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
            let cell: SetListTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            let set = sets[indexPath.row]
            cell.populate(with: set)
            return cell
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionTitle = sectionTitles[indexPath.section]
        if let setListCell = cell as? SetListTableViewCell, let sets = setsBySection[sectionTitle] {
            let set = sets[indexPath.row]
            if set.owned {
                setListCell.collectionStatusView.backgroundColor = UIColor.bricksetOwned
            }
            else if set.wanted {
                setListCell.collectionStatusView.backgroundColor = UIColor.bricksetWanted
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = UIColor.cloudyBlue
        
        header.clipsToBounds = false
        header.layer.shadowColor = UIColor.black.cgColor
        header.layer.shadowOffset = CGSize(width: 0, height: 1)
        header.layer.shadowRadius = 2.0
        header.layer.shadowOpacity = 0.1
    }
    
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
        //NSLog("Filter Options = \(filterOptions)")
        self.filterOptions = filterOptions
        fetchSets()
    }
    
}

