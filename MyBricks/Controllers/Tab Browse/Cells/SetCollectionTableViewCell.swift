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
    @IBOutlet weak var yourRatingView: CosmosView!
    @IBOutlet weak var notesTextView: UITextView!

    @IBOutlet weak var ownedCheckboxButton: UIButton!
    @IBOutlet weak var ownedCountField: UITextField!
    @IBOutlet weak var wantedCheckboxButton: UIButton!

    let maxQuantityLength = 3
    
    var toggleSetOwned : (() -> Void)? = nil
    var toggleSetWanted : (() -> Void)? = nil
    var updateQuantityOwned : ((Int) -> Void)? = nil
    var updateUserNotes : ((String) -> Void)? = nil

    var previousQuantityOwned: Int = 0
    var previousNotesText: String = ""

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

        addOwnedCountInputAccessoryView()
        addUserNotesInputAccessoryView()

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
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func toggleSetOwned(_ sender: UIButton) {
        toggleSetOwned?()
    }
    
    @IBAction func toggleSetWanted(_ sender: UIButton) {
        toggleSetWanted?()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set : Set) -> Void {
        ownedCheckboxButton.isSelected = set.owned ?? false
        wantedCheckboxButton.isSelected = set.wanted ?? false
        
        ownedCountField.isEnabled = set.owned ?? false
        ownedCountField.text = "\(set.quantityOwned ?? 0)"
        //yourRatingView.rating = set.userRating
        //yourRatingView.text = ""
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
    
}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension SetCollectionTableViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        previousQuantityOwned = Int(ownedCountField.text ?? "0") ?? 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxQuantityLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        let newQuantity = Int(ownedCountField.text ?? "0") ?? 0
        if newQuantity != previousQuantityOwned {
            updateQuantityOwned?(newQuantity)
        }
    }
    
}

//==============================================================================
// MARK: - UITextViewDelegate
//==============================================================================

extension SetCollectionTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        previousNotesText = notesTextView.text ?? ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        let newNotes = notesTextView.text ?? ""
        if newNotes != previousNotesText {
            updateUserNotes?(newNotes)
        }
    }
    
}
