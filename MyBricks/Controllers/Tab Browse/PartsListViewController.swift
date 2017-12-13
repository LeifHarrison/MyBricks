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
        tableView.separatorColor = UIColor(white: 0.3, alpha: 0.8)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let set = currentSet {
            let setNumber = set.fullSetNumber
            self.activityIndicator?.startAnimating()
            let completion: (Result<GetPartsResponse>) -> Void = { result in
                self.activityIndicator?.stopAnimating()
                //print("Result: \(result)")
                if result.isSuccess {
                    if let results = result.value?.results {
                        self.elements = results
                        print("Count: \(String(describing: self.elements.count))")
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

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PartsListTableViewCell", for: indexPath) as? PartsListTableViewCell {
            cell.populateWithElement(element)
            cell.selectionStyle = .none
            if let urlString = element.part?.imageURL, let url = URL(string: urlString) {
                cell.partImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3))
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
