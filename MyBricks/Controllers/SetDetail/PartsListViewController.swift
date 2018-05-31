//
//  PartsListViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Alamofire

class PartsListViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!

    var currentSet: Set?
    var lastResponse: GetPartsResponse?
    var elements: [Element] = []
    var isLoading: Bool = false
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPartsList()
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(PartsListTableViewCell.self)
    }
    
    private func fetchPartsList() {
        if let set = currentSet {
            if lastResponse == nil { SimpleActivityHUD.show(overView: view) }
            isLoading = true

            let setNumber = set.fullSetNumber
            let completion: (Result<GetPartsResponse>) -> Void = { result in
                if self.lastResponse == nil { SimpleActivityHUD.hide() }
                self.isLoading = false
                if result.isSuccess {
                    if let response = result.value {
                        self.lastResponse = response
                        if let newElements = response.results {
                            self.elements.append(contentsOf: newElements)
                            self.tableView.reloadData()
                        }
                    }
                }
                else {
                    // Display alert
                }
                
                self.noResultsLabel.isHidden = self.elements.count > 0
            }
            RebrickableServices.shared.getParts(setNumber: setNumber, pageURL: lastResponse?.nextPage, completion: completion)
        }
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension PartsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < elements.count {
            let cell: PartsListTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            let element = elements[indexPath.row]
            cell.populate(with: element)
            cell.selectionStyle = .none
            if let urlString = element.part?.imageURL, let url = URL(string: urlString) {
                cell.partImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
            }
            
            // See if we need to load more species
            let rowsToLoadFromBottom = 5
            let rowsLoaded = elements.count
            if !self.isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom)) {
                let totalRows = self.lastResponse?.count ?? 0
                let remainingPartsToLoad = totalRows - rowsLoaded
                if remainingPartsToLoad > 0 {
                    self.fetchPartsList()
                }
            }

            return cell
        }
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension PartsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Display more part detail?
    }
}
