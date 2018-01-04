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
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!

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

        tryAgainButton.layer.cornerRadius = tryAgainButton.bounds.height / 2

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSearchHistory()
        showInstructions(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        hideNoResultsView(animated: false)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func showBarcodeScanner(_ sender: AnyObject?) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "BarcodeScannerViewController") as? BarcodeScannerViewController {
            hideInstructions(animated: true)
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func tryAgain(_ sender: AnyObject?) {
        noResultsView.isHidden = false

        if searchHistoryItems.count > 0 {
            let lastItem = searchHistoryItems[0]
            if lastItem.searchType == .scan {
                showBarcodeScanner(self)
            }
            else {
                searchBar.becomeFirstResponder()
            }
        }
        else {
            searchBar.becomeFirstResponder()
        }

    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func performSearch(forBarcode code: String) {
        print("performSearch forBarcode: \(code)")
        hideInstructions(animated: true)
        activityIndicator?.startAnimating()
        BricksetServices.shared.getSets(query: code, completion: { result in
            self.activityIndicator?.stopAnimating()
            self.saveSearch(withType: .scan, searchTerm: code)
            if result.isSuccess, let sets = result.value {
                if sets.count == 0 {
                    self.showNoResultsView(animated: true)
                }
                else if sets.count == 1 {
                    // If we only found a single set, go immediately to set detail
                    self.showDetail(forSet: sets.first!)
                }
                else {
                    // If we found more than one, go to Browse Sets
                    self.showResults(sets)
                }
            }
            else {
                self.showNoResultsView(animated: false)
            }
        })
    }
    
    fileprivate func performSearch(forText searchText: String) {
        print("performSearch forText: \(searchText)")
        hideInstructions(animated: true)
        activityIndicator?.startAnimating()
        BricksetServices.shared.getSets(query: searchText, completion: { result in
            self.activityIndicator?.stopAnimating()
            self.saveSearch(withType: .search, searchTerm: searchText)

            if result.isSuccess, let sets = result.value {
                if sets.count == 0 {
                    self.showNoResultsView(animated: false)
                }
                else if sets.count == 1 {
                    // If we only found a single set, go immediately to set detail
                    self.showDetail(forSet: sets.first!)
                }
                else {
                    // If we found more than one, go to Browse Sets
                    self.showResults(sets)
                }
            }
            else {
                self.showNoResultsView(animated: false)
            }
        })
    }
    
    fileprivate func saveSearch(withType searchType: SearchType, searchTerm: String) {
        let container = DataManager.shared.persistentContainer
        
        container.performBackgroundTask( { (context) in
            let request: NSFetchRequest<NSFetchRequestResult> = SearchHistoryItem.fetchRequest()
            request.predicate = NSPredicate(format: "searchTerm == %@", searchTerm)
            do {
                let fetchedItems = try context.fetch(request) as! [SearchHistoryItem]
                if fetchedItems.count >= 1 {
                    if let firstItem = fetchedItems.first {
                        firstItem.searchDate = Date() as NSDate
                        try context.save()
                    }
                }
                else {
                    let searchItem = SearchHistoryItem(context: context)
                    searchItem.searchType = searchType
                    searchItem.searchTerm = searchTerm
                    searchItem.searchDate = Date() as NSDate
                    try context.save()
                }
            }
            catch {
                fatalError("Failed to fetch search history items: \(error)")
            }
            DispatchQueue.main.async {
                self.updateSearchHistory()
            }
        })
    

    }
    
    private func updateSearchHistory() {
        let context = DataManager.shared.persistentContainer.viewContext
        let historyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchHistoryItem")
        historyFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(SearchHistoryItem.searchDate), ascending: false)]
        
        do {
            searchHistoryItems = try context.fetch(historyFetch) as! [SearchHistoryItem]
            tableView.reloadData()
        }
        catch {
            fatalError("Failed to fetch search history: \(error)")
        }
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
    
    //--------------------------------------------------------------------------
    // MARK: - Supplementary Views
    //--------------------------------------------------------------------------

    fileprivate func showInstructions(animated: Bool) {
        instructionsLabel.fadeIn()
    }
    
    fileprivate func hideInstructions(animated: Bool) {
        instructionsLabel.fadeOut()
    }

    fileprivate func showNoResultsView(animated: Bool) {
        noResultsView.fadeIn()
    }
    
    fileprivate func hideNoResultsView(animated: Bool) {
        noResultsView.fadeOut()
    }
    
    fileprivate func showSearchHistory(animated: Bool) {
        tableView.fadeIn()
    }
    
    fileprivate func hideSearchHistory(animated: Bool) {
        tableView.fadeOut()
    }
    
}

//==============================================================================
// MARK: - UISearchBarDelegate
//==============================================================================

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        hideInstructions(animated: true)
        hideNoResultsView(animated: true)
        showSearchHistory(animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hideSearchHistory(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            performSearch(forText: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        showInstructions(animated: true)
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
        controller.dismiss(animated: true, completion: {
            self.performSearch(forBarcode: code)
        })
    }

    func barcodeScanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }

    func barcodeScannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
