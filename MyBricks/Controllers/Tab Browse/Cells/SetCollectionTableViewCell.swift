//
//  SetCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/26/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import Cosmos

class SetCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var ownedContainer: UIView!
    @IBOutlet weak var wantedContainer: UIView!
    @IBOutlet weak var yourRatingView: CosmosView!
    @IBOutlet weak var notesTextView: UITextView!

    @IBOutlet weak var ownedCheckboxButton: UIButton!
    @IBOutlet weak var ownedCountField: UITextField!
    @IBOutlet weak var wantedCheckboxButton: UIButton!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
                
        yourRatingView.settings.starSize = 25.0
        
        notesTextView.layer.borderColor = UIColor.darkGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.cornerRadius = 5.0

        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        
        ownedCheckboxButton.isSelected = false
        wantedCheckboxButton.isSelected = false
        ownedCountField.text = ""
        yourRatingView.rating = 0.0
        notesTextView.text = ""
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        ownedCheckboxButton.isSelected = set.owned ?? false
        wantedCheckboxButton.isSelected = set.wanted ?? false
        ownedCountField.text = "\(set.quantityOwned ?? 0)"
        //yourRatingView.rating = set.userRating
        //yourRatingView.text = ""
        notesTextView.text = set.userNotes

    }

}
