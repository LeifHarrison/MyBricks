//
//  BricksetProfileTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/8/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class BricksetProfileTableViewCell: UITableViewCell {

    static let nibName = "BricksetProfileTableViewCell"
    static let reuseIdentifier = "BricksetProfileTableViewCell"

    @IBOutlet weak var loggedInAsLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!

    var logoutButtonTapped : (() -> Void)?

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoutButton.applyDefaultStyle()
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loggedInAsLabel.text = ""
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        logoutButtonTapped?()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWith(username: String) {
        loggedInAsLabel.attributedText = loggedInAsAttributedDescription(forUsername: username)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private let regularAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.black]
    private let boldAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.black]

    private func loggedInAsAttributedDescription(forUsername username: String) -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "You are logged in as ", attributes: regularAttributes)
        attributedDescription.append(NSAttributedString(string:"\(username)", attributes: boldAttributes))
        return attributedDescription
    }

}
