//
//  ReviewDetailViewController.swift
//  MyBricks
//
//  Created by Leif on 11/21/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class ReviewDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var reviewContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var closeButtonContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!

    var review : SetReview? = nil
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.layer.cornerRadius = closeButton.bounds.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.isScrollEnabled = false
        textView.attributedText = review?.formattedReview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.isScrollEnabled = true
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func closeReview(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
