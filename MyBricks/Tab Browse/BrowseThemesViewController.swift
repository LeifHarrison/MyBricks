//
//  BrowseThemesViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class BrowseThemesViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var allThemes: [Theme] = []
    var sectionTitles: [String] = []
    var themesBySection: [String : [Theme]] = [:]

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ThemeTableViewCell", bundle: nil), forCellReuseIdentifier: "ThemeTableViewCell")
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.title = "Themes"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if allThemes.count == 0 {
            activityIndicator?.startAnimating()
            BricksetServices.sharedInstance.getThemes(completion: { result in
                self.allThemes = result.value ?? []
                self.processThemes()
                self.activityIndicator?.stopAnimating()
                //print("Result: \(result)")
                self.tableView.reloadData()
            })
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func processThemes() {
        for theme in allThemes {
            if let name = theme.name {
                let indexName = String(name.prefix(1))
                var themes: [Theme] = themesBySection[indexName] ?? []
                themes.append(theme)
                themesBySection[indexName] = themes
           }
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeTableViewCell", for: indexPath) as? ThemeTableViewCell
            {
                cell.nameLabel.text = theme.name
                cell.yearsLabel.text = theme.yearsDecription()
                if let count = theme.setCount {
                    cell.setCountLabel.text = "\(count)"
                    if count > 0 {
                        cell.selectionStyle = .default
                        cell.accessoryType = .disclosureIndicator
                    }
                }
                else {
                    cell.setCountLabel.text = ""
                }

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
            if let setsVC = storyboard?.instantiateViewController(withIdentifier: "BrowseSetsViewController") as? BrowseSetsViewController {
                setsVC.theme = theme.name
                show(setsVC, sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
