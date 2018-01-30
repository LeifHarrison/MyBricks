//
//  FilterSelectThemeViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

protocol FilterSelectThemeViewControllerDelegate: class {
    func selectThemeController(_ controller: FilterSelectThemeViewController, didSelectTheme theme: SetTheme?)
}

class FilterSelectThemeViewController: UIViewController {

    let cellIdentifier = "SelectThemeCell"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var currentTheme: SetTheme? = nil
    var availableThemes: [SetTheme] = []
    
    weak var delegate: FilterSelectThemeViewControllerDelegate?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Theme"
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedTheme = currentTheme, let selectedIndex = availableThemes.index(of: selectedTheme) {
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .middle)
        }
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension FilterSelectThemeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableThemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theme = availableThemes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = theme.name
        return cell
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension FilterSelectThemeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = availableThemes[indexPath.row]
        delegate?.selectThemeController(self, didSelectTheme: theme)
        navigationController?.popViewController(animated: true)
    }
    
}
