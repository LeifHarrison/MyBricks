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
                self.activityIndicator?.stopAnimating()
                self.reviews = result.value ?? []
                if let value = result.value {
                    self.reviews = value.sorted {
                        if let date1 = $0.datePosted, let date2 = $1.datePosted {
                            return date1 > date2
                        }
                        else if let _ = $0.datePosted {
                            return false
                        }
                        else if let _ = $0.datePosted {
                            return true
                        }
                        return true
                    }
                }
                self.tableView.reloadData()
            })
        }

    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func showFullReview(_ cell: SetReviewTableViewCell) {
        print("Show full review...")
        var textViewFrame =  view.convert(cell.reviewTextLabel.frame, from: cell.reviewContainerView)
        print("textViewFrame: \(textViewFrame)")
        textViewFrame = textViewFrame.offsetBy(dx: -5, dy: -5)
        let expandingView = UITextView(frame: textViewFrame)
        expandingView.backgroundColor = UIColor.clear
        expandingView.attributedText = cell.reviewTextLabel.attributedText
        view.addSubview(expandingView)

        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.0
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, belowSubview: expandingView)

        let colorOverlay = UIView(frame: view.bounds)
        colorOverlay.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        colorOverlay.alpha = 0.0
        colorOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(colorOverlay, belowSubview: expandingView)

        let endFrame = view.bounds.insetBy(dx: 10, dy: 10)
        UIView.animate(withDuration: 0.5, animations: {
            expandingView.frame = endFrame
            blurEffectView.alpha = 1.0
            colorOverlay.alpha = 1.0
        })
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
            cell.populateWithSetReview(review)
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

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let reviewCell = cell as? SetReviewTableViewCell {
//            print("text label height = \(reviewCell.reviewTextLabel.frame.size.height)")
//        }
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SetReviewTableViewCell {
            showFullReview(cell)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
