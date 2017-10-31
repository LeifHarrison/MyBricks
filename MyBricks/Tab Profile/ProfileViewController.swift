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

    let profileDateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionDivider.backgroundColor = UIColor(white: 0.6, alpha: 0.7)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateProfileFields()
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
            updateProfileInformation()
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

    // MARK: - Updating Profile Information

    fileprivate func updateProfileInformation() {

        // TODO: Implement fetching Profile information once profile
        // service is available

        fadeOutProfileFields()
        profileActivityIndicator.startAnimating()

        // Temporary hack to pretend we're fetching profile information
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.profileActivityIndicator.stopAnimating()
            self.userProfile = UserProfile()
            self.updateProfileFields()
            self.fadeInProfileFields()
        }

//        BricksetServices.sharedInstance.getUserProfile(completion: { result in
//            self.profileActivityIndicator.stopAnimating()
//            if result.isSuccess {
//                self.userProfile = result.value
//                self.updateProfileFields()()
//            }
//        })
    }

    fileprivate func updateProfileFields() -> Void {
        if let profile = self.userProfile {
            self.nameField.text = profile.name
            self.memberSinceField.text = self.profileDateFormatter.string(from: (profile.memberSince ?? Date.init(timeIntervalSinceNow: 0)))
            self.lastOnlineField.text = self.profileDateFormatter.string(from: (profile.lastOnline ?? Date.init(timeIntervalSinceNow: 0)))
            self.countryField.text = profile.country
            self.locationField.text = profile.location
            self.interestsField.text = profile.interests
        }
        else {
            self.nameField.text = nil
            self.memberSinceField.text = nil
            self.lastOnlineField.text = nil
            self.countryField.text = nil
            self.locationField.text = nil
            self.interestsField.text = nil
        }
    }

    fileprivate func fadeOutProfileFields() -> Void {
        let animations = { () -> Void in
            self.nameField.alpha = 0.0
            self.memberSinceField.alpha = 0.0
            self.lastOnlineField.alpha = 0.0
            self.countryField.alpha = 0.0
            self.locationField.alpha = 0.0
            self.interestsField.alpha = 0.0
        }
        UIView.animate(withDuration: 0.25, animations:animations)
    }

    fileprivate func fadeInProfileFields() -> Void {
        let animations = { () -> Void in
            self.nameField.alpha = 1.0
            self.memberSinceField.alpha = 1.0
            self.lastOnlineField.alpha = 1.0
            self.countryField.alpha = 1.0
            self.locationField.alpha = 1.0
            self.interestsField.alpha = 1.0
        }
        UIView.animate(withDuration: 0.25, animations:animations)
    }

    // MARK: - Updating Collection Information

    fileprivate func updateCollectionInformation() {
        fadeOutCollectionFields()
        collectionActivityIndicator.startAnimating()
        BricksetServices.sharedInstance.getCollectionTotals(completion: { result in
            self.collectionActivityIndicator.stopAnimating()
            if result.isSuccess {
                self.collectionTotals = result.value
                self.updateCollectionFields()
                self.fadeInCollectionFields()
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
    
    fileprivate func fadeOutCollectionFields() -> Void {
        let animations = { () -> Void in
            self.ownedSetsField.alpha = 0.0
            self.wantedSetsField.alpha = 0.0
            self.ownedMinifigsField.alpha = 0.0
            self.wantedMinifigsField.alpha = 0.0
        }
        UIView.animate(withDuration: 0.25, animations:animations)
    }

    fileprivate func fadeInCollectionFields() -> Void {
        let animations = { () -> Void in
            self.ownedSetsField.alpha = 1.0
            self.wantedSetsField.alpha = 1.0
            self.ownedMinifigsField.alpha = 1.0
            self.wantedMinifigsField.alpha = 1.0
        }
        UIView.animate(withDuration: 0.25, animations:animations)
    }

}

//==============================================================================
// MARK: - UserCollectionTotals extensions
//==============================================================================

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
        attributedDescription.append(NSAttributedString(string:" sets", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

    func minifigsOwnedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You own ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" minifigs, ", attributes:UserCollectionTotals.regularAttributes))
        attributedDescription.append(NSAttributedString(string:"\(totalDistinctMinifigsOwned ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" different", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

    func minifigsWantedAttributedDescription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You want ", attributes: UserCollectionTotals.regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(totalMinifigsWanted ?? 0)", attributes:UserCollectionTotals.boldAttributes))
        attributedDescription.append(NSAttributedString(string:" minifigs", attributes:UserCollectionTotals.regularAttributes))
        return attributedDescription
    }

}