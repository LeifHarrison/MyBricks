//
//  FilterSelectSortingViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/29/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

protocol FilterSelectSortingViewControllerDelegate: class {
    func selectSortingController(_ controller: FilterSelectSortingViewController, didSelectSortingType sortingType: SortingType)
}

class FilterSelectSortingViewController: UIViewController {

    let cellIdentifier = "SelectSortingTypeCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FilterSelectSortingViewControllerDelegate?
    var filterOptions: FilterOptions = FilterOptions()
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()
        self.title = "Select Sorting"
        
        tableView.alwaysBounceVertical = false
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.filterOptions.selectedYear != nil {
            let item = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetSorting(_:)))
            navigationItem.setRightBarButton(item, animated: false)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func resetSorting(_ sender: AnyObject?) {
        delegate?.selectSortingController(self, didSelectSortingType: .number)
        navigationController?.popViewController(animated: true)
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension FilterSelectSortingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SortingType.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sortingType = SortingType.allValues[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = sortingType.description
        return cell
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension FilterSelectSortingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortingType = SortingType.allValues[indexPath.row]
        delegate?.selectSortingController(self, didSelectSortingType: sortingType)
        navigationController?.popViewController(animated: true)
    }
    
}
