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
    @IBOutlet weak var tableView: UITableView!

    var filterOptions: FilterOptions? = nil
    var showUnreleased: Bool = false
    var browseRequest: Request? = nil
    
    var sectionTitles: [String] = []
    var setsBySection: [String : [Set]] = [:]

    var allSets: [Set] = [] {
        didSet {
            self.processSets()
        }
    }
    
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let options = self.filterOptions, let theme = options.selectedTheme {
            self.title = theme.name
        }
        else {
            self.title = "Sets"
        }
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
            filterVC.filterOptions = self.filterOptions
            
            let navController = UINavigationController(rootViewController: filterVC)
            show(navController, sender: self)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func fetchSets() {
        activityIndicator?.startAnimating()
        if let options = filterOptions {
            let request = GetSetsRequest(theme: options.selectedTheme?.name, subtheme: options.selectedSubtheme?.subtheme, year: options.selectedYear?.year)
            self.browseRequest = BricksetServices.shared.getSets(request, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.activityIndicator?.stopAnimating()
                if result.isSuccess {
                    strongSelf.allSets = result.value ?? []
                    strongSelf.tableView.reloadData()
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SetTableViewCell", for: indexPath) as? SetTableViewCell {
                cell.populateWithSet(set)
                if UIScreen.main.scale > 1.5 {
                    if let urlString = set.largeThumbnailURL, let url = URL(string: urlString) {
                        cell.setImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
                    }
                }
                else {
                    if let urlString = set.thumbnailURL, let url = URL(string: urlString) {
                        cell.setImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
                    }
                }

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
            if let setDetailVC = storyboard?.instantiateViewController(withIdentifier: "SetDetailViewController") as? SetDetailViewController {
                setDetailVC.currentSet = set
                show(setDetailVC, sender: self)
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

