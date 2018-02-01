//
//  BrowseThemesViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class BrowseThemesViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var allThemes: [SetTheme] = []
    var sectionTitles: [String] = []
    var themesBySection: [String : [SetTheme]] = [:]

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if allThemes.count == 0 {
            fetchThemes()
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func fetchThemes() {
        activityIndicator?.startAnimating()
        BricksetServices.shared.getThemes(completion: { result in
            self.allThemes = result.value ?? []
            self.processThemes()
            self.activityIndicator?.stopAnimating()
            self.tableView.reloadData()
        })
    }
    
    fileprivate func processThemes() {
        for theme in allThemes {
            let indexName = String(theme.name.prefix(1))
            var themes: [SetTheme] = themesBySection[indexName] ?? []
            themes.append(theme)
            themesBySection[indexName] = themes
        }
        sectionTitles = themesBySection.keys.sorted()
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension BrowseThemesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        if let themes = themesBySection[sectionTitle] {
            return themes.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionTitle = sectionTitles[indexPath.section]
        if let themes = themesBySection[sectionTitle] {
            let theme = themes[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeTableViewCell", for: indexPath) as? ThemeTableViewCell {
                cell.populateWithTheme(theme)
                return cell
            }
        }
        return UITableViewCell()
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension BrowseThemesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = sectionTitles[indexPath.section]
        if let themes = themesBySection[sectionTitle] {
            let theme = themes[indexPath.row]
            if let browseVC = storyboard?.instantiateViewController(withIdentifier: "BrowseSetsViewController") as? BrowseSetsViewController {
                
                var filterOptions = FilterOptions()
                filterOptions.selectedTheme = theme
                filterOptions.availableThemes = allThemes
                
                browseVC.filterOptions = filterOptions
                show(browseVC, sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

