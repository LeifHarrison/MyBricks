//
//  MySetsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

enum DisplayMode: Int {
    case owned
    case wanted
}

enum GroupingMode: Int {
    case year
    case theme
}

class MySetsViewController: UIViewController {

    @IBOutlet weak var headerView: MySetsHeaderView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var displayMode: DisplayMode = .owned
    var groupingMode: GroupingMode = .year

    var allSets: [Set] = []
    var sectionTitles: [String] = []
    var setsBySection: [String : [Set]] = [:]

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        headerView.showButton.setTitle( displayMode == .owned ? "OWNED" : "WANTED", for: .normal)
        headerView.groupButton.setTitle( groupingMode == .year ? "YEAR" : "THEME", for: .normal)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if allSets.count == 0 {
            updateSets()
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func toggleSetsShown(_ sender: AnyObject?) {
        if displayMode == .owned {
            displayMode = .wanted
            headerView.showButton.setTitle("WANTED", for: .normal)
        }
        else if displayMode == .wanted {
            displayMode = .owned
            headerView.showButton.setTitle("OWNED", for: .normal)
        }
        updateSets()
    }

    @IBAction func toggleGrouping(_ sender: AnyObject?) {
        if groupingMode == .year {
            groupingMode = .theme
            headerView.groupButton.setTitle("THEME", for: .normal)
        }
        else if groupingMode == .theme {
            groupingMode = .year
            headerView.groupButton.setTitle("YEAR", for: .normal)
        }
        processSets()
        self.tableView.reloadData()
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func updateSets() {
        activityIndicator?.startAnimating()
        BricksetServices.sharedInstance.getSets(owned: (displayMode == .owned), wanted: (displayMode == .wanted), completion: { result in
            //print("Result: \(result), Value: \(String(describing: result.value))")
            self.allSets = result.value ?? []
            self.processSets()
            self.activityIndicator?.stopAnimating()
            self.tableView.reloadData()
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

        sectionTitles = setsBySection.keys.sorted(by: >)
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

extension MySetsViewController: UITableViewDelegate {

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

