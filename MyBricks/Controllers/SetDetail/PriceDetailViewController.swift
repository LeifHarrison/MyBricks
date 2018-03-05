//
//  PriceDetailViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 3/1/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class PriceDetailViewController: UIViewController {

    enum TableSection: Int {
        case retailPrice
        case priceGuide
        
        func title() -> String? {
            switch self {
                case .retailPrice: return NSLocalizedString("Retail Price", comment: "")
                case .priceGuide: return NSLocalizedString("Price Guide", comment: "")
            }
        }
        
    }

    @IBOutlet weak var tableView: UITableView!
    
    var currentSet : Set?
    var sections: [TableSection] = []

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()
        title = NSLocalizedString("Price Detail", comment: "")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor(white: 0.3, alpha: 0.8)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.tableFooterView = UIView()
        
        tableView.register(PriceGuideTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSections()
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fetch price guide
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func updateSections() {
        sections.removeAll()
        
        sections.append(.retailPrice)
        sections.append(.priceGuide)
    }
    
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension PriceDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        if section == .retailPrice {
            return currentSet?.retailPrices.count ?? 0
        }
        else if section == .priceGuide {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        if section == .retailPrice {
            if let retailPrice = currentSet?.retailPrices[indexPath.row] {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "PriceDetailTableViewCell", for: indexPath) as? PriceDetailTableViewCell {
                    cell.populate(with: retailPrice)
                    return cell
                }
            }
        }
        else if section == .priceGuide {
            let cell: PriceGuideTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension PriceDetailViewController: UITableViewDelegate {
    
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
    
}
