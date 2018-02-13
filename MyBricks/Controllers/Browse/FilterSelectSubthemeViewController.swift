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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var currentTheme: SetTheme? = nil
    var availableSubthemes: [SetSubtheme] = []
    var selectedSubtheme: SetSubtheme? = nil
    
    weak var delegate: FilterSelectSubthemeViewControllerDelegate?
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        self.title = "Select Subtheme"
        
        let item = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearFilter(_:)))
        navigationItem.setRightBarButton(item, animated: false)

        tableView.tableFooterView = UIView()
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
        if let theme = currentTheme {
            activityIndicator?.startAnimating()
            BricksetServices.shared.getSubthemes(theme: theme.name, completion: { result in
                self.activityIndicator?.stopAnimating()
                if result.isSuccess {
                    self.availableSubthemes = result.value ?? []
                    self.tableView.reloadData()
                    if let subtheme = self.selectedSubtheme, let selectedIndex = self.availableSubthemes.index(of: subtheme) {
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

extension FilterSelectSubthemeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableSubthemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subtheme = availableSubthemes[indexPath.row]
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
        selectedSubtheme = availableSubthemes[indexPath.row]
        delegate?.selectSubthemeController(self, didSelectSubtheme: selectedSubtheme)
        navigationController?.popViewController(animated: true)
    }
    
}
