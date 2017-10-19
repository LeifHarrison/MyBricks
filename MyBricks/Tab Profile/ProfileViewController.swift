//
//  ProfileViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var profileView: UIView!

    @IBOutlet weak var profileDetailView: UIView!
    @IBOutlet weak var profileActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var memberSinceField: UILabel!
    @IBOutlet weak var lastOnlineField: UILabel!
    @IBOutlet weak var countryField: UILabel!
    @IBOutlet weak var locationField: UILabel!
    @IBOutlet weak var interestsField: UILabel!

    @IBOutlet weak var collectionDivider: UIView!
    @IBOutlet weak var collectionDetailView: UIView!
    @IBOutlet weak var collectionActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ownedSetsField: UILabel!
    @IBOutlet weak var wantedSetsField: UILabel!
    @IBOutlet weak var ownedMinifigsField: UILabel!
    @IBOutlet weak var wantedMinifigsField: UILabel!

    var userProfile: UserProfile? = nil
    var collectionTotals: UserCollectionTotals? = nil

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionDivider.backgroundColor = UIColor(white: 0.6, alpha: 0.7)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateCollectionFields()

        let loggedIn = BricksetServices.isLoggedIn()
        setIsLoggedIn(loggedIn, animated: true)
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func logout(_ sender: AnyObject?) {
        setIsLoggedIn(false, animated: true)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    fileprivate func setIsLoggedIn(_ isLoggedIn: Bool, animated: Bool) {

        let buttonItem = isLoggedIn ? UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout)) : nil
        navigationItem.setRightBarButton(buttonItem, animated: animated)

        if (isLoggedIn) {
            transitionViews(fromView: loginView, toView: profileView, animated: animated)
            updateCollectionInformation()
        }
        else {
            transitionViews(fromView: profileView, toView: loginView, animated: animated)
        }
    }

    fileprivate func transitionViews(fromView: UIView, toView: UIView, animated: Bool = true) {
        toView.alpha = 0.0
        let fadeOutBlock = { () -> Void in
            fromView.alpha = 0.0
        }
        let transitionBlock : (Bool) -> () = { _ in
            fromView.isHidden = true
            toView.isHidden = false
            let fadeInBlock = { () -> Void in
                toView.alpha = 1.0
            }
            let completionBlock : (Bool) -> () = { _ in
            }
            UIView.animate(withDuration: animated ? 0.5 : 0, animations: fadeInBlock, completion:completionBlock)
        }
        UIView.animate(withDuration: animated ? 0.5 : 0, animations: fadeOutBlock, completion:transitionBlock)
    }

    fileprivate func updateProfileInformation() {
        // TODO: Implement fetching Profile information once profile
        // service is available
    }

    fileprivate func updateProfileFields() -> Void {
        if let profile = self.userProfile {
            nameField.text = profile.name
            memberSinceField.text = "\(profile.memberSince ?? Date.init(timeIntervalSinceNow: 0))"
            lastOnlineField.text = "\(profile.lastOnline ?? Date.init(timeIntervalSinceNow: 0))"
            countryField.text = profile.country
            locationField.text = profile.location
            interestsField.text = profile.interests
        }
        else {
            nameField.text = nil
            memberSinceField.text = nil
            lastOnlineField.text = nil
            countryField.text = nil
            locationField.text = nil
            interestsField.text = nil
        }
    }

    fileprivate func updateCollectionInformation() {
        collectionActivityIndicator.startAnimating()
        BricksetServices.sharedInstance.getCollectionTotals(completion: { result in
            self.collectionActivityIndicator.stopAnimating()
            if result.isSuccess {
                self.collectionTotals = result.value
                self.updateCollectionFields()
            }
        })
    }

    fileprivate func updateCollectionFields() -> Void {
        if let totals = self.collectionTotals {
            ownedSetsField.attributedText = totals.setsOwnedAttributedDescription()
            wantedSetsField.attributedText = totals.setsWantedAttributedDescription()
            ownedMinifigsField.attributedText = totals.minifigsOwnedAttributedDescription()
            wantedMinifigsField.attributedText = totals.minifigsWantedAttributedDescription()
        }
        else {
            ownedSetsField.text = nil
            wantedSetsField.text = nil
            ownedMinifigsField.text = nil
            wantedMinifigsField.text = nil
        }
    }
    
}

extension UserCollectionTotals {

    static let regularAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.black]
    static let boldAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.black]

    func setsOwnedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You own ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalSetsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" sets, ", attributes:UserCollectionTotals.regularAttributes))
        attributedDescription.append(NSAttributedString(string:"\(totalDistinctSetsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" different", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

    func setsWantedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You want ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalSetsWanted ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" sets, ", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

    func minifigsOwnedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You own ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" minifigs, ", attributes:UserCollectionTotals.regularAttributes))
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" different", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

    func minifigsWantedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You want ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsWanted ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" minifigs, ", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

}
