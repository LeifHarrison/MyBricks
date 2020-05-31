//
//  BrowseThemesViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class BrowseThemesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var allThemes: [SetTheme] = []
    var sectionTitles: [String] = []
    var themesBySection: [String: [SetTheme]] = [:]

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexColor = UIColor.slateBlue
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(ThemeTableViewCell.self)
    }

    fileprivate func fetchThemes() {
        ActivityOverlayView.show(overView: view)
        BricksetServices.shared.getThemes(completion: { result in
            ActivityOverlayView.hide()
            switch result {
                case .success(let themes):
                    self.allThemes = themes
                    self.processThemes()
                    self.tableView.reloadData()
                case .failure(let error):
                    NSLog("Error loading themes: \(error)")
            }
        })
    }
    
    fileprivate func processThemes() {
        for theme in allThemes {
            let indexName = String(theme.theme.prefix(1))
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
            let cell: ThemeTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populateWithTheme(themes[indexPath.row])
            return cell
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

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = UIColor.cloudyBlue
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionTitle = sectionTitles[indexPath.section]
        if let themes = themesBySection[sectionTitle] {
            let theme = themes[indexPath.row]
            if let browseVC = storyboard?.instantiateViewController(withIdentifier: "BrowseSetsViewController") as? BrowseSetsViewController {
                
                var filterOptions = FilterOptions()
                filterOptions.availableThemes = allThemes
                filterOptions.initialTheme = theme
                filterOptions.selectedTheme = theme
                filterOptions.grouping = .year
                
                browseVC.filterOptions = filterOptions
                show(browseVC, sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
