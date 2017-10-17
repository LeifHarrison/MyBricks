//
//  ProfileViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var profileView: UIView!

    @IBOutlet weak var profileDetailView: UIView!
    @IBOutlet weak var profileFieldsView: UIView!

    @IBOutlet weak var collectionDetailView: UIView!
    @IBOutlet weak var collectionLabelsView: UIView!
    @IBOutlet weak var collectionFieldsView: UIView!

    @IBOutlet weak var ownedSetsField: UILabel!
    @IBOutlet weak var wantedSetsField: UILabel!
    @IBOutlet weak var ownedMinifigsField: UILabel!
    @IBOutlet weak var wantedMinifigsField: UILabel!

    var collectionTotals: UserCollectionTotals? = nil

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateCollectionFields()

        let loggedIn = BricksetServices.isLoggedIn()
        if (loggedIn) {
            updateProfileInformation()
        }

        profileView.isHidden = !loggedIn
        loginView.isHidden = loggedIn
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func logout(_ sender: AnyObject?) {
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func updateProfileInformation() {
        activityIndicator.startAnimating()
        BricksetServices.sharedInstance.getCollectionTotals(completion: { result in
            self.activityIndicator.stopAnimating()
            print("Result: \(result)")
            if result.isSuccess {
                self.collectionTotals = result.value
                self.updateCollectionFields()
            }
        })
    }

    fileprivate func updateCollectionFields() -> Void {
        if let totals = self.collectionTotals {
            ownedSetsField.text = totals.setsOwnedDescription()
            wantedSetsField.text = totals.setsWantedDescription()
            ownedMinifigsField.text = totals.minifigsOwnedDescription()
            wantedMinifigsField.text = totals.minifigsWantedDescription()
        }
        else {
            ownedSetsField.text = nil
            wantedSetsField.text = nil
            ownedMinifigsField.text = nil
            wantedMinifigsField.text = nil
        }
    }
    
}
