//
//  FilterSelectThemeViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

protocol FilterSelectThemeViewControllerDelegate: class {
    func selectThemeController(_ controller: FilterSelectThemeViewController, didSelectTheme theme: SetTheme?)
    func selectThemeController(_ controller: FilterSelectThemeViewController, didUpdateAvailableThemes themes: [SetTheme])
}

class FilterSelectThemeViewController: UIViewController {

    let cellIdentifier = "SelectThemeCell"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: FilterSelectThemeViewControllerDelegate?
    var filterOptions: FilterOptions = FilterOptions()    

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()
        self.title = "Select Theme"
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if filterOptions.showingUserSets && filterOptions.selectedTheme != nil {
            let item = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearFilter(_:)))
            navigationItem.setRightBarButton(item, animated: false)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if filterOptions.availableThemes.count == 0 {
            fetchThemes()
        }
        else if let selectedTheme = filterOptions.selectedTheme, let selectedIndex = filterOptions.availableThemes.index(of: selectedTheme) {
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .middle)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func clearFilter(_ sender: AnyObject?) {
        delegate?.selectThemeController(self, didSelectTheme: nil)
        navigationController?.popViewController(animated: true)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func fetchThemes() {
        SimpleActivityHUD.show(overView: view)
        let completion: GetThemesCompletion = { result in
            SimpleActivityHUD.hide()
            if result.isSuccess {
                self.filterOptions.availableThemes = result.value ?? []
                self.delegate?.selectThemeController(self, didUpdateAvailableThemes: self.filterOptions.availableThemes)
                self.tableView.reloadData()
                if let selectedTheme = self.filterOptions.selectedTheme, let selectedIndex = self.filterOptions.availableThemes.index(of: selectedTheme) {
                    self.tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .middle)
                }
            }
        }
        
        if filterOptions.showingUserSets {
            BricksetServices.shared.getThemesForUser(owned: filterOptions.filterOwned, wanted: filterOptions.filterWanted, completion: completion)
        }
        else {
            BricksetServices.shared.getThemes(completion: completion)
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
        return filterOptions.availableThemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theme = filterOptions.availableThemes[indexPath.row]
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
        let theme = filterOptions.availableThemes[indexPath.row]
        delegate?.selectThemeController(self, didSelectTheme: theme)
        navigationController?.popViewController(animated: true)
    }
    
}
