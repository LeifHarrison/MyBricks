//
//  FilterSelectSubthemeViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

protocol FilterSelectSubthemeViewControllerDelegate: class {
    func selectSubthemeController(_ controller: FilterSelectSubthemeViewController, didSelectSubtheme subtheme: SetSubtheme?)
    
}

class FilterSelectSubthemeViewController: UIViewController {

    let cellIdentifier = "SelectSubthemeCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FilterSelectSubthemeViewControllerDelegate?
    var filterOptions: FilterOptions = FilterOptions()
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()
        self.title = "Select Subtheme"
        
        tableView.alwaysBounceVertical = false
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.filterOptions.selectedSubtheme != nil {
            let item = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearFilter(_:)))
            navigationItem.setRightBarButton(item, animated: false)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchSubthemes()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func clearFilter(_ sender: AnyObject?) {
        delegate?.selectSubthemeController(self, didSelectSubtheme: nil)
        navigationController?.popViewController(animated: true)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func fetchSubthemes() {
        if let theme = filterOptions.selectedTheme {
            ActivityOverlayView.show(overView: view)
            let completion: GetSubthemesCompletion = { result in
                ActivityOverlayView.hide()
                switch result {
                    case .success(let subthemes):
                        self.filterOptions.availableSubthemes = subthemes
                        self.tableView.reloadData()
                        if let subtheme = self.filterOptions.selectedSubtheme, let selectedIndex = self.filterOptions.availableSubthemes.index(of: subtheme) {
                            self.tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .middle)
                        }
                    case .failure(let error):
                        NSLog("Error fetching subthemes: \(error.localizedDescription)")
                }
            }
            if filterOptions.showingUserSets {
                BricksetServices.shared.getSubthemes(theme: theme.theme, completion: completion)
                //BricksetServices.shared.getSubthemesForUser(theme: theme.theme, owned: filterOptions.filterOwned, wanted: filterOptions.filterWanted, completion: completion)
            }
            else {
                BricksetServices.shared.getSubthemes(theme: theme.theme, completion: completion)
            }

        }
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension FilterSelectSubthemeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.availableSubthemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subtheme = filterOptions.availableSubthemes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let setCount = subtheme.setCount {
            cell.textLabel?.text = subtheme.subtheme + " (\(setCount))"
        }
        else {
            cell.textLabel?.text = subtheme.subtheme
        }
        return cell
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension FilterSelectSubthemeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subtheme = filterOptions.availableSubthemes[indexPath.row]
        delegate?.selectSubthemeController(self, didSelectSubtheme: subtheme)
        navigationController?.popViewController(animated: true)
    }
    
}
