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
        case sorting
        case grouping

        func title() -> String? {
            switch self {
                case .general: return NSLocalizedString("General", comment: "")
                case .collection: return NSLocalizedString("Collection", comment: "")
                case .sorting: return NSLocalizedString("Sorting", comment: "")
                case .grouping: return NSLocalizedString("Grouping", comment: "")
            }
        }

        func numberOfRows() -> Int {
            switch self {
                case .general: return TableRowsGeneral.count
                case .collection: return TableRowsCollection.count
                case .sorting: return TableRowsSorting.count
                case .grouping: return TableRowsGrouping.count
            }
        }
        
    }
    
    enum TableRowsGeneral: Int {
        case theme
        case subtheme
        case year
        case unreleased

        init?(indexPath: IndexPath) { self.init(rawValue: indexPath.row) }
        
        static var count: Int { return 4 }
        
        func title() -> String? {
            switch self {
                case .theme: return NSLocalizedString("Theme", comment: "")
                case .subtheme: return NSLocalizedString("Subtheme", comment: "")
                case .year: return NSLocalizedString("Year", comment: "")
                case .unreleased: return nil
            }
        }

    }

    enum TableRowsCollection: Int {
        case collection
        
        init?(indexPath: IndexPath) { self.init(rawValue: indexPath.row) }

        static var count: Int { return 1 }
    }

    enum TableRowsSorting: Int {
        case sortingType
        case sortingDirection

        init?(indexPath: IndexPath) { self.init(rawValue: indexPath.row) }
        
        static var count: Int { return 2 }
        
        func title() -> String? {
            switch self {
            case .sortingType: return NSLocalizedString("Sort By", comment: "")
            case .sortingDirection: return nil
            }
        }
        
    }
    
    enum TableRowsGrouping: Int {
        case collection
        
        init?(indexPath: IndexPath) { self.init(rawValue: indexPath.row) }
        
        static var count: Int { return 1 }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var doneButton: UIButton!

    var filterOptions: FilterOptions = FilterOptions()

    weak var delegate: FilterViewControllerDelegate?

    private var sections: [TableSection] = []
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.cloudyBlue
        self.title = "Filter"

        setupTableView()
        doneButton.applyDefaultStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sections.removeAll()
        sections.append(.general)
        if BricksetServices.isLoggedIn() {
            sections.append(.collection)
        }
        sections.append(.sorting)
        sections.append(.grouping)

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
            filterOptions.filterOwned = true
        }
        else {
            filterOptions.selectedTheme = filterOptions.initialTheme
            filterOptions.filterOwned = false
        }
        
        filterOptions.selectedSubtheme = nil
        filterOptions.selectedYear = nil
        filterOptions.filterNotOwned = false
        filterOptions.filterWanted = false
        filterOptions.showUnreleased = false

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
        else if let viewController = segue.destination as? FilterSelectSortingViewController {
            viewController.delegate = self
            viewController.filterOptions = filterOptions
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func setupTableView() {
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
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
        return section.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if section == .general, let row = TableRowsGeneral(indexPath: indexPath) {
            if row == .unreleased {
                if let cell = tableView.dequeueReusableCell(withIdentifier: FilterUnreleasedTableViewCell.reuseIdentifier, for: indexPath) as? FilterUnreleasedTableViewCell {
                    cell.populate(with: filterOptions)
                    cell.toggleFilterShowUnreleased = { value in
                        self.filterOptions.showUnreleased = value
                    }
                    return cell
                }
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralFilterCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = row.title()
                
                switch row {
                    case .theme:
                        cell.detailTextLabel?.text = filterOptions.selectedTheme?.name ?? "All"
                    case .subtheme:
                        cell.detailTextLabel?.text = filterOptions.selectedSubtheme?.name ?? "All"
                    case .year:
                        cell.detailTextLabel?.text = filterOptions.selectedYear?.name ?? "All"
                    case .unreleased:
                        break // Do Nothing - handled above, hopefully
                }
                
                return cell
            }
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
        else if section == .sorting, let row = TableRowsSorting(indexPath: indexPath) {
            if row == .sortingType {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralFilterCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = row.title()
                cell.detailTextLabel?.text = filterOptions.sortingSelection.sortingType.description
                return cell
            }
            else if row == .sortingDirection {
                if let cell = tableView.dequeueReusableCell(withIdentifier: FilterSortingDirectionTableViewCell.reuseIdentifier, for: indexPath) as? FilterSortingDirectionTableViewCell {
                    cell.populate(with: filterOptions)
                    cell.sortingDirectionSelected = { value in
                        self.filterOptions.sortingSelection.direction = value
                    }
                    return cell
                }
            }
        }
        else if section == .grouping {
            if let cell = tableView.dequeueReusableCell(withIdentifier: FilterGroupingTableViewCell.reuseIdentifier, for: indexPath) as? FilterGroupingTableViewCell {
                cell.populate(with: filterOptions)
                cell.groupingTypeSelected = { value in
                    self.filterOptions.grouping = value
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
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = UIColor.cloudyBlue
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let title = sections[section].title() {
            return title.uppercased()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        if section == .general, let row = TableRowsGeneral(indexPath: indexPath) {
            switch row {
                case .theme: performSegue(withIdentifier: "showSelectThemeView", sender: self)
                case .subtheme: performSegue(withIdentifier: "showSelectSubthemeView", sender: self)
                case .year: performSegue(withIdentifier: "showSelectYearView", sender: self)
                case .unreleased:  break // Do Nothing
            }
        }
        if section == .sorting, let row = TableRowsSorting(indexPath: indexPath) {
            if row == .sortingType {
                performSegue(withIdentifier: "showSelectSortingView", sender: self)
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
// MARK: - FilterSelectYearViewControllerDelegate
//==============================================================================

extension FilterViewController: FilterSelectYearViewControllerDelegate {
    
    func selectYearController(_ controller: FilterSelectYearViewController, didSelectYear year: SetYear?) {
        filterOptions.selectedYear = year
        tableView.reloadData()
    }
    
}

//==============================================================================
// MARK: - FilterSelectSortingViewControllerDelegate
//==============================================================================

extension FilterViewController: FilterSelectSortingViewControllerDelegate {
    
    func selectSortingController(_ controller: FilterSelectSortingViewController, didSelectSortingType sortingType: SortingType) {
        //NSLog("sortingType = \(sortingType)")
        filterOptions.sortingSelection.sortingType = sortingType
        let indexPath = IndexPath(row: TableRowsSorting.sortingType.rawValue, section: TableSection.sorting.rawValue)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
}
