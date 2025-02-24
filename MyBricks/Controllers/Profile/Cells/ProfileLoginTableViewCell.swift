//
//  ProfileLoginTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/8/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class ProfileLoginTableViewCell: BorderedGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet var signupBottomConstraint: NSLayoutConstraint!

    var loginButtonTapped: (() -> Void)?
    var signupButtonTapped: (() -> Void)?

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        statusLabel.text = NSLocalizedString("profile.login.helptext", comment:"")
        loginButton.setTitle("LOGIN", for: .normal)
        
        signupBottomConstraint.isActive = true
        signupLabel.isHidden = false
        signupButton.isHidden = false

    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        loginButtonTapped?()
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        signupButtonTapped?()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(for serviceAPI: AuthenticatedServiceAPI) {
        if let logoImage = serviceAPI.logoImage {
            logoImageView.image = logoImage
        }
        if let username = serviceAPI.userName {
            statusLabel.attributedText = self.loggedInAsAttributedDescription(forUsername: username)
            loginButton.setTitle("LOGOUT", for: .normal)
            
            signupBottomConstraint.isActive = false
            signupLabel.isHidden = true
            signupButton.isHidden = true
        }
        else {
            statusLabel.text = NSLocalizedString("profile.login.helptext", comment:"")
            loginButton.setTitle("LOGIN", for: .normal)
            
            signupBottomConstraint.isActive = true
            signupLabel.isHidden = false
            signupButton.isHidden = false
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private let regularAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black]
    private let boldAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.black]
    
    private func loggedInAsAttributedDescription(forUsername username: String) -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You are logged in as ", attributes: regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(username)", attributes: boldAttributes))
        return attributedDescription
    }
    
}
