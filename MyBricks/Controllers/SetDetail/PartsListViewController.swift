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

    var currentSet : Set?
    var elements : [Element] = []

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(PartsListTableViewCell.self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPartsList()
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func fetchPartsList() {
        if let set = currentSet {
            SimpleActivityHUD.show(overView: view)

            let setNumber = set.fullSetNumber
            let completion: (Result<GetPartsResponse>) -> Void = { result in
                SimpleActivityHUD.hide()
                if result.isSuccess {
                    if let results = result.value?.results {
                        self.elements = results
                        self.tableView.reloadData()
                    }
                }
                else {
                    // Display alert
                }
            }
            RebrickableServices.shared.getParts(setNumber: setNumber, completion: completion)
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
        let element = elements[indexPath.row]
        let cell: PartsListTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.populateWithElement(element)
        cell.selectionStyle = .none
        if let urlString = element.part?.imageURL, let url = URL(string: urlString) {
            cell.partImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
        }
        return cell
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
