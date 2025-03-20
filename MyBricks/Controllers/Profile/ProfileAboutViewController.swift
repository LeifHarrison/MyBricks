//
//  ProfileAboutViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/31/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class ProfileAboutViewController: UIViewController {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var rateAppButton: UIButton!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactUsTopConstraint: NSLayoutConstraint!

    let smallScreenScale: CGFloat = 0.85
    
    // -------------------------------------------------------------------------
    // MARK: - View Lifecycle
    // -------------------------------------------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        versionLabel.text = "Version " + Bundle.main.versionNumber + " (" + Bundle.main.gitVersion + ")"
        buildLabel.text = "Build " + Bundle.main.buildNumber + " (" + Bundle.main.buildDate + ")"
        
        if UIScreen.main.bounds.height < 570 {
            headerTopConstraint.constant = 25
            contactUsTopConstraint.constant = 25

            headerImageView.transform = CGAffineTransform(scaleX: smallScreenScale, y: smallScreenScale)
            
            leftImageView.layer.anchorPoint = CGPoint(x: 0, y: 1)
            leftImageView.transform = CGAffineTransform(translationX: -(leftImageView.frame.width / 2), y: (leftImageView.frame.height / 2))
            leftImageView.transform = leftImageView.transform.scaledBy(x: smallScreenScale, y: smallScreenScale)

            rightImageView.layer.anchorPoint = CGPoint(x: 1, y: 1)
            rightImageView.transform = CGAffineTransform(translationX: (rightImageView.frame.width / 2), y: (rightImageView.frame.height / 2))
            rightImageView.transform = rightImageView.transform.scaledBy(x: smallScreenScale, y: smallScreenScale)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------
    
    @IBAction func contactUs(_ sender: UIButton?) {
        NSLog("contactUs")
    }
    
    @IBAction func rateApp(_ sender: UIButton?) {
        NSLog("rateApp")
    }

}
