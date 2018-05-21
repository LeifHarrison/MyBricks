//
//  CollectionDetailViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/14/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

extension Notification.Name {
    public struct Collection {
        public static let DidUpdate = Notification.Name(rawValue: "app.mybricks.notification.name.collection.didUpdate")
    }
}

extension Notification {
    public struct Key {
        public static let Set = "app.mybricks.notification.key.set"
    }
}

class CollectionDetailViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var ownedContainer: UIView!
    @IBOutlet weak var ownedCheckboxButton: UIButton!
    @IBOutlet weak var ownedCountField: UITextField!
    @IBOutlet weak var wantedCheckboxButton: UIButton!
    @IBOutlet weak var wantedContainer: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var removeRatingButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    
    let maxQuantityLength = 3
    
    var currentSet: Set?
    var previousQuantityOwned: Int = 0
    var previousNotesText: String = ""
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.addBorder()
        contentView.addGradientBackground()
        
        ownedContainer.layer.cornerRadius = ownedContainer.bounds.height / 2
        wantedContainer.layer.cornerRadius = wantedContainer.bounds.height / 2
        
        ownedCountField.layer.borderColor = UIColor.lightNavy.cgColor
        ownedCountField.layer.borderWidth = 1.0
        ownedCountField.layer.cornerRadius = 2.0

        notesTextView.layer.borderColor = UIColor.lightNavy.cgColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.cornerRadius = 5.0
        
        setupRatingView()
        addOwnedCountInputAccessoryView()
        addUserNotesInputAccessoryView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let set = currentSet {
            ownedCheckboxButton.isSelected = set.owned
            self.ownedContainer.backgroundColor = ownedCheckboxButton.isSelected ? UIColor(named: "bricksetOwned") : UIColor.clear
            wantedCheckboxButton.isSelected = set.wanted
            self.wantedContainer.backgroundColor = wantedCheckboxButton.isSelected ? UIColor(named: "bricksetWanted") : UIColor.clear
            
            ownedCountField.isEnabled = set.owned
            ownedCountField.text = "\(set.quantityOwned ?? 0)"
            ratingView.rating = Double(set.userRating ?? 0)
            notesTextView.text = set.userNotes
        }

    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func toggleSetOwned(_ sender: UIButton) {
        if var set = currentSet, let setID = set.setID {
            set.owned = !set.owned
            set.quantityOwned = set.owned ? 1 : nil
            
            ownedCheckboxButton.isSelected = set.owned
            ownedContainer.backgroundColor = set.owned ? UIColor(named: "bricksetOwned") : UIColor.clear
            ownedCountField.isEnabled = set.owned
            ownedCountField.text = "\(set.quantityOwned ?? 0)"

            BricksetServices.shared.setCollectionOwns(setID: setID, owned: set.owned, completion: { result in
                if result.isSuccess {
                    self.currentSet = set
                    self.notifySetUpdated(set: set)
                }
            })
        }
        
    }
    
    @IBAction func toggleSetWanted(_ sender: UIButton) {
        if var set = currentSet, let setID = set.setID {
            set.wanted = !set.wanted
            
            wantedCheckboxButton.isSelected = set.wanted
            wantedContainer.backgroundColor = set.wanted ? UIColor(named: "bricksetWanted") : UIColor.clear

            BricksetServices.shared.setCollectionWants(setID: setID, wanted: set.wanted, completion: { result in
                if result.isSuccess {
                    self.currentSet = set
                    self.notifySetUpdated(set: set)
                }
            })
        }
    }
    
    @IBAction func removeRating(_ sender: UIButton) {
        ratingView.rating = 0.0
        updateRating(newRating: 0)
    }
    
    @objc func cancelEditingQuantity() {
        ownedCountField.text = "\(previousQuantityOwned)"
        ownedCountField.resignFirstResponder()
    }
    
    @objc func doneEditingQuantity() {
        ownedCountField.resignFirstResponder()
        let newQuantity = Int(ownedCountField.text ?? "0") ?? 0
        if newQuantity != previousQuantityOwned {
            updateQuantityOwned(newQuantity: newQuantity)
        }

    }
    
    @objc func cancelEditingNotes() {
        notesTextView.text = previousNotesText
        notesTextView.resignFirstResponder()
    }
    
    @objc func doneEditingNotes() {
        notesTextView.resignFirstResponder()
        let newNotes = notesTextView.text ?? ""
        if newNotes != previousNotesText {
            updateUserNotes(newNotes: newNotes)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func addOwnedCountInputAccessoryView() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        doneToolbar.barStyle = UIBarStyle.default
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditingQuantity))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditingQuantity))
        
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
    
    private func setupRatingView() {
        ratingView.settings.starSize = 28.0
        ratingView.settings.starMargin = 4
        ratingView.settings.emptyImage = #imageLiteral(resourceName: "ratingStarEmpty")
        ratingView.settings.filledImage = #imageLiteral(resourceName: "ratingStarFilled")

        ratingView.didFinishTouchingCosmos = { rating in
            self.updateRating(newRating: Int(rating))
        }
    }
    
    private func updateQuantityOwned(newQuantity: Int) {
        if var set = currentSet, let setID = set.setID {
            set.owned = (newQuantity > 0) ? true : false
            set.quantityOwned = newQuantity

            BricksetServices.shared.setCollectionQuantityOwned(setID: setID, quantityOwned: newQuantity, completion: { result in
                if result.isSuccess {
                    self.currentSet = set
                    self.notifySetUpdated(set: set)
                }
            })
        }
    }
    
    private func updateRating(newRating: Int) {
        if var set = self.currentSet, let setID = set.setID {
            BricksetServices.shared.setUserRating(setID: setID, rating: newRating, completion: { result in
                if result.isSuccess {
                    set.userRating = newRating
                    self.currentSet = set
                    self.notifySetUpdated(set: set)
                }
            })
        }
    }
    
    private func updateUserNotes(newNotes: String) {
        if var set = currentSet, let setID = set.setID {
            BricksetServices.shared.setCollectionUserNotes(setID: setID, notes: newNotes, completion: { result in
                if result.isSuccess {
                    set.userNotes = newNotes
                    self.currentSet = set
                    self.notifySetUpdated(set: set)
                }
            })
        }
    }
    
    private func notifySetUpdated(set: Set) {
        NotificationCenter.default.post(name: Notification.Name.Collection.DidUpdate, object: self, userInfo: [Notification.Key.Set: set])
    }
    
}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension CollectionDetailViewController: UITextFieldDelegate {
    
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

extension CollectionDetailViewController: UITextViewDelegate {
    
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
