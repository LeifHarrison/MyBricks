//
//  SearchViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 7/12/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

import AVFoundation

class SearchViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
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

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Show search history
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text {
            print("searchText: \(searchText)")
            
            activityIndicator?.startAnimating()
            BricksetServices.shared.getSets(query: searchText, completion: { result in
                self.activityIndicator?.stopAnimating()

                if let sets = result.value {
                    print("Results Count: \(sets.count)")
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}

//==============================================================================
// MARK: - BarcodeScannerCodeDelegate
//==============================================================================

extension SearchViewController: BarcodeScannerDelegate {

    func barcodeScanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("didCaptureCode: \(code), type: \(type)")
        
        BricksetServices.shared.getSets(query: code, completion: { result in
            if result.isSuccess {
                if let sets = result.value {
                    print("Results Count: \(sets.count)")
                    // If we only found a single set, go immediately to set detail
                    if sets.count == 1 {
                        self.showDetail(forSet: sets.first!)
                    }
                }
            }
            controller.dismiss(animated: true, completion: {
                //self.tableView.reloadData()
            })
        })

        //controller.reset()
    }

    func barcodeScanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }

    func barcodeScannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
