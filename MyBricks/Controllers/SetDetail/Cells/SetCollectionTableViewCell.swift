//
//  SetCollectionTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/26/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

class SetCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var ownedContainer: UIView!
    @IBOutlet weak var wantedContainer: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var notesTextView: UITextView!

    @IBOutlet weak var ownedCheckboxButton: UIButton!
    @IBOutlet weak var ownedCountField: UITextField!
    @IBOutlet weak var wantedCheckboxButton: UIButton!

    let maxQuantityLength = 3
    
    var setUpdated: ((Set?) -> Void)? = nil
    
    var currentSet: Set? = nil
    var previousQuantityOwned: Int = 0
    var previousNotesText: String = ""

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
                
        ratingView.settings.starSize = 25.0
        
        notesTextView.layer.borderColor = UIColor.darkGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.cornerRadius = 5.0

        addOwnedCountInputAccessoryView()
        addUserNotesInputAccessoryView()

        ratingView.didFinishTouchingCosmos = { rating in
            if var set = self.currentSet, let setID = set.setID {
                BricksetServices.shared.setUserRating(setID: setID, rating: Int(rating), completion: { result in
                    if result.isSuccess {
                        set.userRating = Int(rating)
                        self.setUpdated?(set)
                        self.currentSet = set
                    }
                })
            }
        }

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
        ratingView.rating = 0.0
        notesTextView.text = ""
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func toggleSetOwned(_ sender: UIButton) {
        if var set = currentSet, let setID = set.setID, let owned = set.owned {
            BricksetServices.shared.setCollectionOwns(setID: setID, owned: !owned, completion: { result in
                if result.isSuccess {
                    set.owned = !owned
                    set.quantityOwned = !owned ? 1 : nil
                    
                    self.ownedCheckboxButton.isSelected = set.owned ?? false
                    self.ownedCountField.isEnabled = set.owned ?? false
                    self.ownedCountField.text = "\(set.quantityOwned ?? 0)"

                    self.setUpdated?(set)
                    self.currentSet = set
                }
            })
        }

    }
    
    @IBAction func toggleSetWanted(_ sender: UIButton) {
        if var set = currentSet, let setID = set.setID, let wanted = set.wanted {
            BricksetServices.shared.setCollectionWants(setID: setID, wanted: !wanted, completion: { result in
                if result.isSuccess {
                    set.wanted = !wanted
                    self.wantedCheckboxButton.isSelected = set.wanted ?? false
                    self.setUpdated?(set)
                    self.currentSet = set
                }
            })
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        currentSet = set
        
        ownedCheckboxButton.isSelected = set.owned ?? false
        wantedCheckboxButton.isSelected = set.wanted ?? false
        
        ownedCountField.isEnabled = set.owned ?? false
        ownedCountField.text = "\(set.quantityOwned ?? 0)"
        ratingView.rating = Double(set.userRating ?? 0)
        notesTextView.text = set.userNotes
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @objc func cancelButtonAction() {
        ownedCountField.text = "\(previousQuantityOwned)"
        ownedCountField.resignFirstResponder()
    }
    
    @objc func doneButtonAction() {
        ownedCountField.resignFirstResponder()
    }
    
    @objc func cancelEditingNotes() {
        notesTextView.text = previousNotesText
        notesTextView.resignFirstResponder()
    }
    
    @objc func doneEditingNotes() {
        notesTextView.resignFirstResponder()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func addOwnedCountInputAccessoryView() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(cancel)
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        ownedCountField.inputAccessoryView = doneToolbar
    }
    
    private func addUserNotesInputAccessoryView() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditingNotes))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditingNotes))
        
        var items = [UIBarButtonItem]()
        items.append(cancel)
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        notesTextView.inputAccessoryView = doneToolbar
    }
    
    private func updateQuantityOwned(newQuantity: Int) {
        if var set = currentSet, let setID = set.setID {
            BricksetServices.shared.setCollectionQuantityOwned(setID: setID, quantityOwned: newQuantity, completion: { result in
                if result.isSuccess {
                    set.owned = (newQuantity > 0) ? true : false
                    set.quantityOwned = newQuantity
                    self.setUpdated?(set)
                    self.currentSet = set
                }
            })
        }
    }
    
    private func updateUserNotes(newNotes: String) {
        if var set = currentSet, let setID = set.setID {
            BricksetServices.shared.setCollectionUserNotes(setID: setID, notes: newNotes, completion: { result in
                if result.isSuccess {
                    set.userNotes = newNotes
                    self.setUpdated?(set)
                    self.currentSet = set
                }
            })
        }
    }
}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension SetCollectionTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        previousQuantityOwned = Int(ownedCountField.text ?? "0") ?? 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxQuantityLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let newQuantity = Int(ownedCountField.text ?? "0") ?? 0
        if newQuantity != previousQuantityOwned {
            updateQuantityOwned(newQuantity: newQuantity)
        }
    }
    
}

//==============================================================================
// MARK: - UITextViewDelegate
//==============================================================================

extension SetCollectionTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        previousNotesText = notesTextView.text ?? ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let newNotes = notesTextView.text ?? ""
        if newNotes != previousNotesText {
            updateUserNotes(newNotes: newNotes)
        }
    }
    
}
