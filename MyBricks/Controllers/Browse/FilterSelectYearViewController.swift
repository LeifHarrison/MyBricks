//
//  FilterSelectYearViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

protocol FilterSelectYearViewControllerDelegate: AnyObject {
    func selectYearController(_ controller: FilterSelectYearViewController, didSelectYear year: SetYear?)
}

class FilterSelectYearViewController: UIViewController {

    let cellIdentifier = "SelectYearCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FilterSelectYearViewControllerDelegate?
    var filterOptions: FilterOptions = FilterOptions()
    
    // -------------------------------------------------------------------------
    // MARK: - View Lifecycle
    // -------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()
        self.title = "Select Year"
        
        tableView.alwaysBounceVertical = false
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.filterOptions.selectedYear != nil {
            let item = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearFilter(_:)))
            navigationItem.setRightBarButton(item, animated: false)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchYears()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------
    
    @IBAction func clearFilter(_ sender: AnyObject?) {
        delegate?.selectYearController(self, didSelectYear: nil)
        navigationController?.popViewController(animated: true)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------
    
    fileprivate func fetchYears() {
        if let theme = filterOptions.selectedTheme {
            ActivityOverlayView.show(overView: view)
            let completion: GetYearsCompletion = { result in
                ActivityOverlayView.hide()
                switch result {
                    case .success(let availableYears ):
                        self.filterOptions.availableYears = availableYears.sorted {
                            return $0.year > $1.year
                        }
                        self.tableView.reloadData()
                        if let year = self.filterOptions.selectedYear, let selectedIndex = self.filterOptions.availableYears.firstIndex(of: year) {
                            self.tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .middle)
                        }
                    case .failure(let error):
                        NSLog("Error in \(#function): \(error.localizedDescription)")
                }
            }
            if filterOptions.showingUserSets {
                // BricksetServices.shared.getYearsForUser(theme: theme.theme, owned: filterOptions.filterOwned, wanted: filterOptions.filterWanted, completion: completion)
                BricksetServices.shared.getYears(theme: theme.theme, completion: completion)
            }
            else {
                BricksetServices.shared.getYears(theme: theme.theme, completion: completion)
            }
        }
    }
    
}

// =============================================================================
// MARK: - UITableViewDataSource
// =============================================================================

extension FilterSelectYearViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.availableYears.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let year = filterOptions.availableYears[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = year.year
        return cell
    }
    
}

// =============================================================================
// MARK: - UITableViewDelegate
// =============================================================================

extension FilterSelectYearViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let year = filterOptions.availableYears[indexPath.row]
        delegate?.selectYearController(self, didSelectYear: year)
        navigationController?.popViewController(animated: true)
    }
    
}
