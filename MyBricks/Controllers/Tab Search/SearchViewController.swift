//
//  SearchViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var theme : String?
    
    var allSets: [Set] = []
    var sectionTitles: [String] = []
    var setsBySection: [String : [Set]] = [:]

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SetTableViewCell", bundle: nil), forCellReuseIdentifier: "SetTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func processSets() {
        sectionTitles.removeAll()
        setsBySection.removeAll()
        
        for set in allSets {
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

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Show search history
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            print("searchText: \(searchText)")
            
            activityIndicator?.startAnimating()
            BricksetServices.shared.getSets(query: searchText, completion: { result in
                self.allSets = result.value ?? []
                print("Results Count: \(self.allSets.count)")
                self.processSets()
                self.activityIndicator?.stopAnimating()
                self.tableView.reloadData()
            })

        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension SearchViewController: UITableViewDataSource {
    
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SetTableViewCell", for: indexPath) as? SetTableViewCell
            {
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
                
                cell.nameLabel.text = set.name
                cell.setNumberLabel.text = set.number
                cell.subthemeLabel.text = set.subtheme
                cell.piecesLabel.text = "\(set.pieces ?? 0)"
                cell.minifigsLabel.text = "\(set.minifigs ?? 0)"
                
                cell.retiredView.isHidden = !(set.isRetired())
                cell.retiredSpacingConstraint.isActive = set.isRetired()
                
                cell.ownedView.isHidden = !(set.owned ?? true)
                cell.wantedView.isHidden = !cell.ownedView.isHidden || !(set.wanted ?? true)
                
                if cell.hasAmbiguousLayout {
                    print("\(cell.constraintsAffectingLayout(for: .vertical))")
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

extension SearchViewController: UITableViewDelegate {
    
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
