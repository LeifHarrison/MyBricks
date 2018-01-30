//
//  FilterSelectYearViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

protocol FilterSelectYearViewControllerDelegate: class {
    func selectYearController(_ controller: FilterSelectYearViewController, didSelectYear year: SetYear?)
}

class FilterSelectYearViewController: UIViewController {

    let cellIdentifier = "SelectYearCell"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var currentTheme: SetTheme? = nil
    var availableYears: [SetYear] = []
    var selectedYear: SetYear? = nil

    weak var delegate: FilterSelectYearViewControllerDelegate?
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Year"
        
        let item = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearFilter(_:)))
        navigationItem.setRightBarButton(item, animated: false)
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchYears()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func clearFilter(_ sender: AnyObject?) {
        delegate?.selectYearController(self, didSelectYear: nil)
        navigationController?.popViewController(animated: true)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func fetchYears() {
        if let theme = currentTheme {
            activityIndicator?.startAnimating()
            BricksetServices.shared.getYears(theme: theme.name, completion: { result in
                self.activityIndicator?.stopAnimating()
                if result.isSuccess {
                    self.availableYears = result.value ?? []
                    self.tableView.reloadData()
                    if let year = self.selectedYear, let selectedIndex = self.availableYears.index(of: year) {
                        self.tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .middle)
                    }
                }
            })
        }
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension FilterSelectYearViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableYears.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let year = availableYears[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = year.year
        return cell
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension FilterSelectYearViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let year = availableYears[indexPath.row]
        delegate?.selectYearController(self, didSelectYear: year)
        navigationController?.popViewController(animated: true)
    }
    
}
