//
//  ReviewsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var currentSet: SetDetail?
    var reviews: [SetReview] = []

    let transition = ReviewDetailAnimator()
    var expandedCell: SetReviewTableViewCell?

    // -------------------------------------------------------------------------
    // MARK: - View Lifecycle
    // -------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchReviews()
    }

    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------

    lazy var animatedTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        return textView
    }()

    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.register(SetReviewTableViewCell.self)
    }
    
    private func fetchReviews() {
        if let set = currentSet, let setID = set.setID {
            ActivityOverlayView.show(overView: view)
            BricksetServices.shared.getReviews(setID: setID, completion: { result in
                ActivityOverlayView.hide()
                switch result {
                    case .success(let reviews):
                        self.reviews = reviews.sorted {
                            if let date1 = $0.datePosted, let date2 = $1.datePosted {
                                return date1 > date2
                            }
                            else if $0.datePosted != nil {
                                return false
                            }
                            else if $1.datePosted != nil {
                                return true
                            }
                            return true
                        }
                        self.tableView.reloadData()
                    case .failure(let error):
                        NSLog("Error getting set reviews: \(error.localizedDescription)")
                }
            })
        }
    }
    
    private func showFullReview(_ review: SetReview, fromCell cell: SetReviewTableViewCell) {
        expandedCell = cell
        
        if let reviewDetailVC = storyboard!.instantiateViewController(withIdentifier: "ReviewDetailViewController") as? ReviewDetailViewController {
            reviewDetailVC.modalPresentationStyle = .overFullScreen
            reviewDetailVC.review =  review
            reviewDetailVC.transitioningDelegate = self
            present(reviewDetailVC, animated: true, completion: nil)
        }
    }
    
}

// =============================================================================
// MARK: - UITableViewDataSource
// =============================================================================

extension ReviewsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SetReviewTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let review = reviews[indexPath.row]
        cell.populate(with: review)
        cell.useSmallLayout = (tableView.frame.size.width < 375)
        
        cell.moreButtonTapped = {
            self.showFullReview(review, fromCell: cell)
        }
        
        return cell
    }

}

// =============================================================================
// MARK: - UITableViewDelegate
// =============================================================================

extension ReviewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let review = reviews[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? SetReviewTableViewCell {
            showFullReview(review, fromCell: cell)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// =============================================================================
// MARK: - UIViewControllerTransitioningDelegate
// =============================================================================

extension ReviewsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true

        if let originFrame = expandedCell?.reviewContainerView.frame {
            transition.originFrame = view.convert(originFrame, from: expandedCell?.contentView)
        }
        
        var finalFrame = tableView.frame
        if let navBar = navigationController?.navigationBar {
            finalFrame.origin.y -= navBar.frame.size.height
            finalFrame.size.height += navBar.frame.size.height
        }
        if let tabBar = tabBarController?.tabBar {
            finalFrame.size.height += tabBar.frame.size.height
        }
        transition.finalFrame = finalFrame
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        transition.dismissCompletion = { }
        return transition
    }
    
}
