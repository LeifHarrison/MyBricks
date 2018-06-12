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
    var browseRequest: Request?
    
    var allSets: [Set] = []
    var sectionTitles: [String] = []
    var setsBySection: [String: [Set]] = [:]
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem

        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(collectionUpdated(_:)), name: Notification.Name.Collection.DidUpdate, object: nil)
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if filterOptions.showingUserSets {
            self.title = "My Sets"
        }
        else if filterOptions.searchTerm != nil {
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    // MARK: - Collection Update Notification
    //--------------------------------------------------------------------------
    
    @objc private func collectionUpdated(_ notification: Notification) {
        if let updatedSet = notification.userInfo?[Notification.Key.Set] as? Set {
            if let index = allSets.index(where: { $0.setID == updatedSet.setID }) {
                allSets[index] = updatedSet
                for (sectionIndex, sectionTitle) in sectionTitles.enumerated() {
                    if var setsForSection = setsBySection[sectionTitle], let rowIndex = setsForSection.index(where: { $0.setID == updatedSet.setID }) {
                        setsForSection[rowIndex] = updatedSet
                        setsBySection[sectionTitle] = setsForSection
                        tableView.reloadRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .fade)
                    }
                }
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.register(SetListTableViewCell.self)
    }
    
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
                if let error = result.error as? URLError, error.code == .cancelled {
                    return
                }
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
                switch grouping {
                    case .theme    : indexName = set.theme ?? ""
                    case .subtheme : indexName = set.subtheme ?? ""
                    case .year     : indexName = set.year ?? ""
                }
            }
            
            var sets: [Set] = setsBySection[indexName] ?? []
            sets.append(set)
            setsBySection[indexName] = sets
        }
        
        if let grouping = filterOptions.grouping, grouping == .year {
            sectionTitles = setsBySection.keys.sorted(by: >)
        }
        else {
            sectionTitles = setsBySection.keys.sorted(by: <)
        }

    }

    fileprivate func showTableView(faded: Bool) {
        let animations = { () -> Void in
            self.tableView.alpha = faded ? 0.3 : 1.0
        }
        UIView.animate(withDuration: 0.2, animations:animations)
    }

    internal func updateDisplay(animated: Bool = false) {
        
        if self.allSets.count > 0 {
            let item = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(showFilters(_:)))
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
            cell.populate(with: set, options: filterOptions)
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
        self.filterOptions = filterOptions
        fetchSets()
    }
    
}

//==============================================================================
// MARK: - UIViewControllerPreviewingDelegate
//==============================================================================

extension BrowseSetsViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            let sectionTitle = sectionTitles[indexPath.section]
            if let sets = setsBySection[sectionTitle] {
                let set = sets[indexPath.row]
                let detailStoryboard = UIStoryboard(name: "SetDetail", bundle: nil)
                if let detailVC = detailStoryboard.instantiateInitialViewController() as? SetDetailViewController {
                    detailVC.currentSet = set
                    detailVC.isPreview = true
                    return detailVC
                }
            }
            return nil
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let detailVC = viewControllerToCommit as? SetDetailViewController {
            detailVC.isPreview = false
        }
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

}
