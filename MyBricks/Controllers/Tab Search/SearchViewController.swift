//
//  SearchViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import AVFoundation
import CoreData

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var searchHistoryItems: [SearchHistoryItem] = []
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()

        if AVCaptureDevice.default(for: AVMediaType.video) == nil && !UIDevice.isSimulator {
            navigationItem.setRightBarButtonItems([], animated: false)

            let instructionsText = NSLocalizedString("Search for Lego sets by title, set number, theme or subtheme", comment: "")
            let attributedInstructions = NSMutableAttributedString(string: instructionsText)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            paragraphStyle.alignment = .center
            attributedInstructions.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedInstructions.length))

            instructionsLabel.attributedText = attributedInstructions
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let moc = DataManager.shared.persistentContainer.viewContext
        let historyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchHistoryItem")
        historyFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(SearchHistoryItem.searchDate), ascending: false)]

        do {
            searchHistoryItems = try moc.fetch(historyFetch) as! [SearchHistoryItem]
            tableView.reloadData()
        }
        catch {
            fatalError("Failed to fetch search history: \(error)")
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func showBarcodeScanner(_ sender: AnyObject?) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "BarcodeScannerViewController") as? BarcodeScannerViewController {
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func performSearch(forBarcode code: String) {
        activityIndicator?.startAnimating()
        BricksetServices.shared.getSets(query: code, completion: { result in
            self.activityIndicator?.stopAnimating()
            self.saveSearch(withType: .scan, searchTerm: code)
            if result.isSuccess {
                if let sets = result.value {
                    // If we only found a single set, go immediately to set detail
                    if sets.count == 1 {
                        self.showDetail(forSet: sets.first!)
                    }
                }
            }
        })
    }
    
    fileprivate func performSearch(forText searchText: String) {
        activityIndicator?.startAnimating()
        BricksetServices.shared.getSets(query: searchText, completion: { result in
            self.activityIndicator?.stopAnimating()
            self.saveSearch(withType: .search, searchTerm: searchText)
            if result.isSuccess, let sets = result.value {
                if sets.count == 1 {
                    // If we only found a single set, go immediately to set detail
                    self.showDetail(forSet: sets.first!)
                }
                else if sets.count > 1 {
                    // If we found more than one, go to Browse Sets
                    self.showResults(sets)
                }
                else {
                    // Otherwise, show 'No Results' view
                }
            }
            else {
                // Show 'No Results' view
            }
        })
    }
    
    fileprivate func saveSearch(withType searchType: SearchType, searchTerm: String) {
        let context = DataManager.shared.persistentContainer.viewContext
        let searchItem = NSEntityDescription.insertNewObject(forEntityName: "SearchHistoryItem", into: context) as! SearchHistoryItem
        searchItem.searchType = searchType
        searchItem.searchTerm = searchTerm
        searchItem.searchDate = Date() as NSDate
        DataManager.shared.saveContext()
    }
    
    fileprivate func showDetail(forSet set: Set) {
        let browseStoryboard = UIStoryboard(name: "Browse", bundle: nil)
        if let setDetailVC = browseStoryboard.instantiateViewController(withIdentifier: "SetDetailViewController") as? SetDetailViewController {
            setDetailVC.currentSet = set
            show(setDetailVC, sender: self)
        }
    }
    
    fileprivate func showResults(_ results: [Set]) {
        let browseStoryboard = UIStoryboard(name: "Browse", bundle: nil)
        if let browseVC = browseStoryboard.instantiateViewController(withIdentifier: "BrowseSetsViewController") as? BrowseSetsViewController {
            browseVC.allSets = results
            show(browseVC, sender: self)
        }
    }
    
}

//==============================================================================
// MARK: - UISearchBarDelegate
//==============================================================================

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        tableView.alpha = 0.0
        tableView.isHidden = false

        // Show search history
        let animations: (() -> Void) = {
            self.tableView.alpha = 1.0
            self.instructionsLabel.alpha = 0.0
        }
        let completion: ((Bool) -> Void) = { (Bool) -> Void in
            self.instructionsLabel.isHidden = true
        }
        UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        instructionsLabel.alpha = 0.0
        instructionsLabel.isHidden = false
        
        // Hide search history
        let animations: (() -> Void) = {
            self.tableView.alpha = 0.0
            self.instructionsLabel.alpha = 1.0
        }
        let completion: ((Bool) -> Void) = { (Bool) -> Void in
            self.tableView.isHidden = true
        }
        UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            performSearch(forText: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistoryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = searchHistoryItems[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryTableViewCell", for: indexPath) as? SearchHistoryTableViewCell {
            cell.populateWithSearchHistoryItem(item)
            return cell
        }
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let item = searchHistoryItems[indexPath.row]
        if item.searchType == .search {
            performSearch(forText: item.searchTerm)
        }
        else {
            performSearch(forBarcode: item.searchTerm)
        }
    }

}

//==============================================================================
// MARK: - BarcodeScannerCodeDelegate
//==============================================================================

extension SearchViewController: BarcodeScannerDelegate {

    func barcodeScanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        controller.dismiss(animated: true, completion: nil)
        performSearch(forBarcode: code)
    }

    func barcodeScanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }

    func barcodeScannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
