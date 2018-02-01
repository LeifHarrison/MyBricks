//
//  FilterViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 1/19/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate: class {
    func filterViewController(_ controller: FilterViewController, didUpdateFilterOptions filterOptions: FilterOptions)
}


class FilterViewController: UIViewController {

    enum TableSection: Int {
        case general
        case user
    }
    
    enum TableRowGeneral: Int {
        case theme
        case subtheme
        case year
        
        init?(indexPath: IndexPath) { self.init(rawValue: indexPath.row) }
        
        static var numberOfRows: Int { return 3 }
        
        func title() -> String? {
            switch self {
            case .theme: return NSLocalizedString("Theme", comment: "")
            case .subtheme: return NSLocalizedString("Subtheme", comment: "")
            case .year: return NSLocalizedString("Year", comment: "")
            }
        }

    }

    enum TableRowUser: Int {
        case owned
        case wanted
        
        init?(indexPath: IndexPath) { self.init(rawValue: indexPath.row) }

        static var numberOfRows: Int { return 2 }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var filterOptions: FilterOptions? = nil

    weak var delegate: FilterViewControllerDelegate?

    private var sections: [TableSection] = []
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        self.title = "Filter"

        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sections.removeAll()
        sections.append(.general)
        if BricksetServices.isLoggedIn() {
            sections.append(.user)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func cancel(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyFilters(_ sender: AnyObject?) {
        if let options = self.filterOptions {
            delegate?.filterViewController(self, didUpdateFilterOptions: options)
        }
        dismiss(animated: true, completion: nil)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? FilterSelectThemeViewController {
            if let themes = filterOptions?.availableThemes {
                viewController.availableThemes = themes
            }
            viewController.currentTheme = filterOptions?.selectedTheme
            viewController.delegate = self
        }
        else if let viewController = segue.destination as? FilterSelectSubthemeViewController {
            viewController.currentTheme = filterOptions?.selectedTheme
            viewController.delegate = self
            viewController.selectedSubtheme = filterOptions?.selectedSubtheme
        }
        else if let viewController = segue.destination as? FilterSelectYearViewController {
            viewController.currentTheme = filterOptions?.selectedTheme
            viewController.delegate = self
            viewController.selectedYear = filterOptions?.selectedYear
        }
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension FilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = TableSection(rawValue:section)
        if section == .general {
            return TableRowGeneral.numberOfRows
        }
        else if section == .user {
            //return TableRowUser.numberOfRows
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if section == .general, let row = TableRowGeneral(indexPath: indexPath) {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "GeneralFilterCell")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = row.title()
            
            switch row {
            case .theme: cell.detailTextLabel?.text = filterOptions?.selectedTheme?.name ?? "All"
            case .subtheme: cell.detailTextLabel?.text = filterOptions?.selectedSubtheme?.subtheme ?? "All"
            case .year: cell.detailTextLabel?.text = filterOptions?.selectedYear?.year ?? "All"
            }
            
            return cell
        }
        else if section == .user {
        }
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        if section == .general, let row = TableRowGeneral(indexPath: indexPath) {
            switch row {
            case .theme: performSegue(withIdentifier: "showSelectThemeView", sender: self)
            case .subtheme: performSegue(withIdentifier: "showSelectSubthemeView", sender: self)
            case .year: performSegue(withIdentifier: "showSelectYearView", sender: self)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//==============================================================================
// MARK: - FilterSelectThemeViewControllerDelegate
//==============================================================================

extension FilterViewController: FilterSelectThemeViewControllerDelegate {
    
    func selectThemeController(_ controller: FilterSelectThemeViewController, didSelectTheme theme: SetTheme?) {
        if var options = self.filterOptions {
            options.selectedTheme = theme
            options.selectedSubtheme = nil
            options.selectedYear = nil
            self.filterOptions = options
            tableView.reloadData()
        }
    }
    
}

//==============================================================================
// MARK: - FilterSelectSubthemeViewControllerDelegate
//==============================================================================

extension FilterViewController: FilterSelectSubthemeViewControllerDelegate {
    
    func selectSubthemeController(_ controller: FilterSelectSubthemeViewController, didSelectSubtheme subtheme: SetSubtheme?) {
        if var options = self.filterOptions {
            options.selectedSubtheme = subtheme
            self.filterOptions = options
            tableView.reloadData()
        }
    }
    
}

//==============================================================================
// MARK: - FilterSelectSubthemeViewControllerDelegate
//==============================================================================

extension FilterViewController: FilterSelectYearViewControllerDelegate {
    
    func selectYearController(_ controller: FilterSelectYearViewController, didSelectYear year: SetYear?) {
        if var options = self.filterOptions {
            options.selectedYear = year
            self.filterOptions = options
            tableView.reloadData()
        }
    }
    
}
