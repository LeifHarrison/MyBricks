//
//  SearchViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import Alamofire
import AVFoundation
import CoreData

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!

    var searchRequest: Request?

    var searchHistoryItems: [SearchHistoryItem] = []
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        tryAgainButton.applyDefaultStyle()

        if AVCaptureDevice.default(for: AVMediaType.video) == nil && !UIDevice.isSimulator {
            navigationItem.setRightBarButtonItems([], animated: false)
            instructionsLabel.text = NSLocalizedString("Search for Lego sets by title, set number, theme or subtheme", comment: "")
        }
        
        instructionsLabel.applyInstructionsStyle()
        // Make the middle 'OR' bold
        if let text = instructionsLabel.attributedText, let range = text.string.range(of: "OR") {
            let substringRange = NSRange(range, in:text.string)
            let mutableText = NSMutableAttributedString(attributedString: text)
            mutableText.addAttribute(.font, value: instructionsLabel.font.bold(), range: substringRange)
            instructionsLabel.attributedText = mutableText
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(with:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name: .UIKeyboardWillHide, object: nil)

        updateSearchHistory()
        showInstructions(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)

        hideNoResultsView(animated: false)
        if let request = self.searchRequest {
            request.cancel()
        }
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
    // MARK: - Keyboard Notifications
    //--------------------------------------------------------------------------
    
    @objc private func keyboardWillShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        var contentInset = self.tableView.contentInset
        contentInset.bottom += keyboardFrame.height
        if let tabController = self.tabBarController {
            contentInset.bottom -= tabController.tabBar.frame.height
        }

        self.tableView.contentInset = contentInset
        self.tableView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func keyboardWillHide(with notification: Notification) {
        var contentInset = self.tableView.contentInset
        contentInset.bottom = 0

        self.tableView.contentInset = contentInset
        self.tableView.scrollIndicatorInsets = contentInset
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func performSearch(forBarcode code: String) {
        performSearch(searchType: .scan, searchTerm: code)
    }
    
    fileprivate func performSearch(forText searchText: String) {
        performSearch(searchType: .search, searchTerm: searchText)
    }
    
    fileprivate func performSearch(searchType: SearchType, searchTerm: String) {
        
        if let request = self.searchRequest {
            request.cancel()
        }

        hideInstructions(animated: true)
        ActivityOverlayView.show(overView: view)
        let request = GetSetsRequest(query: searchTerm)
        self.searchRequest = BricksetServices.shared.getSets(request, completion: { result in
            ActivityOverlayView.hide()
            self.saveSearch(withType: searchType, searchTerm: searchTerm)
            
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
                    self.showResults(searchType: searchType, searchTerm: searchTerm, results: sets)
                }
            }
            else {
                self.showNoResultsView(animated: false)
            }
        })
    }
    
    fileprivate func saveSearch(withType searchType: SearchType, searchTerm: String) {
        let container = DataManager.shared.persistentContainer
        
        let saveBlock = { (context: NSManagedObjectContext) in
            let request: NSFetchRequest<NSFetchRequestResult> = SearchHistoryItem.fetchRequest()
            request.predicate = NSPredicate(format: "searchTerm == %@", searchTerm)
            do {
                if let fetchedItems = try context.fetch(request) as? [SearchHistoryItem], fetchedItems.count >= 1 {
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
        }
        container.performBackgroundTask(saveBlock)
    }
    
    private func updateSearchHistory() {
        let context = DataManager.shared.persistentContainer.viewContext
        let historyFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchHistoryItem")
        historyFetch.sortDescriptors = [NSSortDescriptor(key: #keyPath(SearchHistoryItem.searchDate), ascending: false)]
        
        do {
            if let fetchedItems = try context.fetch(historyFetch) as? [SearchHistoryItem] {
                searchHistoryItems = fetchedItems
                tableView.reloadData()
            }
        }
        catch {
            fatalError("Failed to fetch search history: \(error)")
        }
    }
    
    fileprivate func showDetail(forSet set: Set) {
        let detailStoryboard = UIStoryboard(name: "SetDetail", bundle: nil)
        if let detailVC = detailStoryboard.instantiateInitialViewController() as? SetDetailViewController {
            detailVC.currentSet = set
            show(detailVC, sender: self)
        }
    }
    
    fileprivate func showResults(searchType: SearchType, searchTerm: String, results: [Set]) {
        let browseStoryboard = UIStoryboard(name: "Browse", bundle: nil)
        if let browseVC = browseStoryboard.instantiateViewController(withIdentifier: "BrowseSetsViewController") as? BrowseSetsViewController {

            var filterOptions = FilterOptions()
            filterOptions.searchType = searchType
            filterOptions.searchTerm = searchTerm
            
            browseVC.filterOptions = filterOptions
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
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hideSearchHistory(animated: true)
        searchBar.setShowsCancelButton(false, animated: true)
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
        NSLog("Error scanning barcode: \(error)")
    }

    func barcodeScannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
