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
        case collection
        
        func title() -> String? {
            switch self {
                case .general: return NSLocalizedString("General", comment: "")
                case .collection: return NSLocalizedString("Collection", comment: "")
            }
        }

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

    enum TableRowCollection: Int {
        case collection
        
        init?(indexPath: IndexPath) { self.init(rawValue: indexPath.row) }

        static var numberOfRows: Int { return 1 }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var resetButton: UIButton!

    var filterOptions: FilterOptions = FilterOptions()

    weak var delegate: FilterViewControllerDelegate?

    private var sections: [TableSection] = []
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        self.title = "Filter"

        resetButton.applyDefaultStyle()
        
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sections.removeAll()
        sections.append(.general)
        if BricksetServices.isLoggedIn() {
            sections.append(.collection)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func cancel(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyFilters(_ sender: AnyObject?) {
        if filterOptions.showingUserSets && !filterOptions.filterOwned && !filterOptions.filterWanted {
            let title = NSLocalizedString("Invalid Filters", comment: "")
            let message = NSLocalizedString("You must select 'Owned' or 'Wanted' when viewing your collection.\n\nFor browsing sets you do not own or want, use the 'Browse' tab.", comment: "")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let actionButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(actionButton)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        delegate?.filterViewController(self, didUpdateFilterOptions: filterOptions)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetFilters(_ sender: AnyObject?) {
        if filterOptions.showingUserSets {
            filterOptions.selectedTheme = nil
            filterOptions.selectedSubtheme = nil
            filterOptions.selectedYear = nil
            filterOptions.filterOwned = true
            filterOptions.filterWanted = false
        }
        else {
            filterOptions.selectedTheme = filterOptions.initialTheme
            filterOptions.selectedSubtheme = nil
            filterOptions.selectedYear = nil
            filterOptions.filterOwned = false
            filterOptions.filterNotOwned = false
            filterOptions.filterWanted = false
        }
        tableView.reloadData()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Storyboards and Segues
    //--------------------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? FilterSelectThemeViewController {
            viewController.delegate = self
            viewController.filterOptions = filterOptions
        }
        else if let viewController = segue.destination as? FilterSelectSubthemeViewController {
            viewController.delegate = self
            viewController.filterOptions = filterOptions
        }
        else if let viewController = segue.destination as? FilterSelectYearViewController {
            viewController.delegate = self
            viewController.filterOptions = filterOptions
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
        let section = sections[section]
        if section == .general {
            return TableRowGeneral.numberOfRows
        }
        else if section == .collection {
            return TableRowCollection.numberOfRows
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if section == .general, let row = TableRowGeneral(indexPath: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralFilterCell", for: indexPath)
            //let cell = UITableViewCell(style: .value1, reuseIdentifier: "GeneralFilterCell")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = row.title()
            
            switch row {
                case .theme:
                    cell.detailTextLabel?.text = filterOptions.selectedTheme?.name ?? "All"
                case .subtheme:
                    cell.detailTextLabel?.text = filterOptions.selectedSubtheme?.name ?? "All"
                case .year:
                    cell.detailTextLabel?.text = filterOptions.selectedYear?.name ?? "All"
            }
            
            return cell
        }
        else if section == .collection {
            if let cell = tableView.dequeueReusableCell(withIdentifier: FilterCollectionTableViewCell.reuseIdentifier, for: indexPath) as? FilterCollectionTableViewCell {
                cell.populate(with: filterOptions)
                cell.toggleFilterOwned = { value in
                    self.filterOptions.filterOwned = value
                }
                cell.toggleFilterNotOwned = { value in
                    self.filterOptions.filterNotOwned = value
                }
                cell.toggleFilterWanted = { value in
                    self.filterOptions.filterWanted = value
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let title = sections[section].title() {
            return title.uppercased()
        }
        return nil
    }
    
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
        filterOptions.selectedTheme = theme
        filterOptions.selectedSubtheme = nil
        filterOptions.selectedYear = nil
        tableView.reloadData()
    }
    
    func selectThemeController(_ controller: FilterSelectThemeViewController, didUpdateAvailableThemes themes: [SetTheme]) {
        filterOptions.availableThemes = themes
    }

}

//==============================================================================
// MARK: - FilterSelectSubthemeViewControllerDelegate
//==============================================================================

extension FilterViewController: FilterSelectSubthemeViewControllerDelegate {
    
    func selectSubthemeController(_ controller: FilterSelectSubthemeViewController, didSelectSubtheme subtheme: SetSubtheme?) {
        filterOptions.selectedSubtheme = subtheme
        tableView.reloadData()
    }
    
}

//==============================================================================
// MARK: - FilterSelectSubthemeViewControllerDelegate
//==============================================================================

extension FilterViewController: FilterSelectYearViewControllerDelegate {
    
    func selectYearController(_ controller: FilterSelectYearViewController, didSelectYear year: SetYear?) {
        filterOptions.selectedYear = year
        tableView.reloadData()
    }
    
}
