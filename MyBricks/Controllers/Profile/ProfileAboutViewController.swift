//
//  ProfileAboutViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/31/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class ProfileAboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        versionLabel.text = " Version " + Bundle.main.versionNumber + " (" + Bundle.main.gitVersion + ")"
        buildLabel.text = Bundle.main.buildDate
    }
    
}
