//
//  BrowseSetsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/10/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import AlamofireImage

class BrowseSetsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var theme : String?
    
    var allSets: [Set] = []
    var sectionTitles: [String] = []
    var setsBySection: [String : [Set]] = [:]

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SetTableViewCell", bundle: nil), forCellReuseIdentifier: "SetTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 61
        tableView.sectionIndexBackgroundColor = UIColor.clear
        //tableView.separatorInset = UIEdgeInsets()
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let theme = self.theme {
            self.title = theme
        }
        else {
            self.title = "Sets"
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if allSets.count == 0 {
            activityIndicator?.startAnimating()
            BricksetServices.sharedInstance.getSets(theme: (theme ?? ""), completion: { result in
                self.allSets = result
                self.processSets()
                self.activityIndicator?.stopAnimating()
                //print("Result: \(result)")
                self.tableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func processSets() {
        for set in allSets {
            if let year = set.year {
                let indexName = String(year)
                var sets: [Set] = setsBySection[indexName] ?? []
                sets.append(set)
                setsBySection[indexName] = sets
            }
        }
        sectionTitles = setsBySection.keys.sorted(by: >)
    }

}

extension BrowseSetsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sectionTitles[section]
        if let sets = setsBySection[sectionTitle] {
            return sets.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionTitle = sectionTitles[indexPath.section]
        if let sets = setsBySection[sectionTitle] {
            let set = sets[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SetTableViewCell", for: indexPath) as? SetTableViewCell
            {
                cell.nameLabel.text = set.name
                cell.setNumberLabel.text = set.number

                if let urlString = set.thumbnailURL, let url = URL(string: urlString) {
                    cell.setImageView.af_setImage(withURL: url)
                }

                return cell
            }
        }
        return UITableViewCell()
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

}

extension BrowseSetsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sectionTitle = sectionTitles[indexPath.section]
//        if let themes = themesBySection[sectionTitle] {
//            let theme = themes[indexPath.row]
//            print("Selected Theme: \(theme.name ?? "")")
//        }
    }
}

