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
    
    var currentSet: SetDetail?
    var sections: [TableSection] = []

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Price Detail", comment: "")
        setupTableView()
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
    
    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(PriceGuideTableViewCell.self)
    }
    
    private func updateSections() {
        sections.removeAll()
        sections.append(.retailPrice)
        //sections.append(.priceGuide)
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
            return currentSet?.retailPrices?.count ?? 0
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
            if let retailPrice = currentSet?.retailPrices?[indexPath.row] {
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
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = UIColor.cloudyBlue
        
        header.clipsToBounds = false
        header.layer.shadowColor = UIColor.black.cgColor
        header.layer.shadowOffset = CGSize(width: 0, height: 1)
        header.layer.shadowRadius = 2.0
        header.layer.shadowOpacity = 0.1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let title = sections[section].title() {
            return title.uppercased()
        }
        return nil
    }
    
}
