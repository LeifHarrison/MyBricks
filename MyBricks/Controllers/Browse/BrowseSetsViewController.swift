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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var headerView: BrowseHeaderView!
    @IBOutlet weak var tableView: UITableView!

    var filterOptions: FilterOptions? = nil
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

        let item = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilters(_:)))
        navigationItem.setRightBarButton(item, animated: false)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName:SetListTableViewCell.nibName, bundle:nil), forCellReuseIdentifier: SetListTableViewCell.reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let options = self.filterOptions, let theme = options.selectedTheme {
            self.title = theme.name
        }
        else {
            self.title = "Browse Sets"
        }
        
        updateDisplay(animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if allSets.count == 0 {
            fetchSets()
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
            filterVC.filterOptions = self.filterOptions ?? FilterOptions()
            
            let navController = UINavigationController(rootViewController: filterVC)
            show(navController, sender: self)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func fetchSets() {
        
        showTableView(faded: true)
        activityIndicator?.startAnimating()
        
        if let options = filterOptions {
            let request = GetSetsRequest(theme: options.selectedTheme?.name, subtheme: options.selectedSubtheme?.subtheme, year: options.selectedYear?.year, owned: options.filterOwned, wanted: options.filterWanted)
            self.browseRequest = BricksetServices.shared.getSets(request, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                
                strongSelf.activityIndicator?.stopAnimating()
                strongSelf.showTableView(faded: false)

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
    }
    
    fileprivate func processSets() {
        sectionTitles.removeAll()
        setsBySection.removeAll()

        // Have to filter for "Not Owned" ourselves
        if let options = filterOptions, options.filterNotOwned {
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

    private func showTableView(faded: Bool) {
        let animations = { () -> Void in
            self.tableView.alpha = faded ? 0.3 : 1.0
        }
        UIView.animate(withDuration: 0.2, animations:animations)
    }

    private func updateDisplay(animated: Bool = false) {
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

