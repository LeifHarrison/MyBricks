//
//  ReviewsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var currentSet : Set?
    var reviews : [SetReview] = []

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let set = currentSet, let setID = set.setID {
            self.activityIndicator?.startAnimating()
            BricksetServices.shared.getReviews(setID: setID, completion: { result in
                self.reviews = result.value ?? []
                self.activityIndicator?.stopAnimating()
                self.tableView.reloadData()
            })
        }

    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func showFullReview(_ cell: SetReviewTableViewCell) {
        print("Show full review...")
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension ReviewsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = reviews[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SetReviewTableViewCell", for: indexPath) as? SetReviewTableViewCell {
            cell.populateWithSetReview(review: review)
            cell.useSmallLayout = (tableView.frame.size.width < 375)

            cell.moreButtonTapped = {
                self.showFullReview(cell)
            }
            
            return cell
        }
        return UITableViewCell()
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension ReviewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("cell height = \(cell.frame.size.height)")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SetReviewTableViewCell {
            showFullReview(cell)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}