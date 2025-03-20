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
    
    var currentSet: SetDetail?
    var previousQuantityOwned: Int = 0
    var previousNotesText: String = ""
    
    // -------------------------------------------------------------------------
    // MARK: - View Lifecycle
    // -------------------------------------------------------------------------
    
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
            ownedCheckboxButton.isSelected = set.isOwned
            self.ownedContainer.backgroundColor = ownedCheckboxButton.isSelected ? UIColor(named: "bricksetOwned") : UIColor.clear
            wantedCheckboxButton.isSelected = set.isWanted
            self.wantedContainer.backgroundColor = wantedCheckboxButton.isSelected ? UIColor(named: "bricksetWanted") : UIColor.clear
            
            ownedCountField.isEnabled = set.isOwned
            ownedCountField.text = "\(set.collection?.qtyOwned ?? 0)"
            ratingView.rating = Double(set.collection?.rating ?? 0)
            notesTextView.text = set.collection?.notes
        }

    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------
    
    @IBAction func toggleSetOwned(_ sender: UIButton) {
        if let set = currentSet, let setID = set.setID {
            set.collection?.owned = !set.isOwned
            set.collection?.qtyOwned = set.isOwned ? 1 : 0
            
            ownedCheckboxButton.isSelected = set.isOwned
            ownedContainer.backgroundColor = set.isOwned ? UIColor(named: "bricksetOwned") : UIColor.clear
            ownedCountField.isEnabled = set.isOwned
            ownedCountField.text = "\(set.collection?.qtyOwned ?? 0)"

            let request = BricksetSetCollectionRequest(own: set.isOwned, qtyOwned: set.collection?.qtyOwned)
            BricksetServices.shared.setCollection(setID: setID, request: request, completion: { result in
                switch result {
                    case .success:
                        self.currentSet = set
                        self.notifySetUpdated(set: set)
                    case .failure(let error):
                        NSLog("Error setting item owned: \(error)")
                }
            })
        }
        
    }
    
    @IBAction func toggleSetWanted(_ sender: UIButton) {
        if let set = currentSet, let setID = set.setID {
            set.collection?.wanted = !set.isWanted
            
            wantedCheckboxButton.isSelected = set.isWanted
            wantedContainer.backgroundColor = set.isWanted ? UIColor(named: "bricksetWanted") : UIColor.clear

            let request = BricksetSetCollectionRequest(own: set.isOwned, want: set.isWanted, qtyOwned: set.collection?.qtyOwned)
            BricksetServices.shared.setCollection(setID: setID, request: request, completion: { result in
                switch result {
                    case .success:
                        self.currentSet = set
                        self.notifySetUpdated(set: set)
                    case .failure(let error):
                        NSLog("Error setting item wanted: \(error)")
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
    
    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------
    
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
        if let set = currentSet, let setID = set.setID {
            set.collection?.owned = (newQuantity > 0) ? true : false
            set.collection?.qtyOwned = newQuantity

            let request = BricksetSetCollectionRequest(qtyOwned: newQuantity)
            BricksetServices.shared.setCollection(setID: setID, request: request, completion: { result in
                switch result {
                    case .success:
                        self.currentSet = set
                        self.notifySetUpdated(set: set)
                    case .failure(let error):
                        NSLog("Error setting quantity owned: \(error.localizedDescription)")
                }
            })
        }
    }
    
    private func updateRating(newRating: Int) {
        if let set = self.currentSet, let setID = set.setID {
            let request = BricksetSetCollectionRequest(rating: newRating)
            BricksetServices.shared.setCollection(setID: setID, request: request, completion: { result in
                switch result {
                    case .success:
                        set.collection?.rating = newRating
                        self.currentSet = set
                        self.notifySetUpdated(set: set)
                    case .failure(let error):
                        NSLog("Error setting user rating: \(error.localizedDescription)")
                }
            })
        }
    }
    
    private func updateUserNotes(newNotes: String) {
        if let set = currentSet, let setID = set.setID {
            let request = BricksetSetCollectionRequest(notes: newNotes)
            BricksetServices.shared.setCollection(setID: setID, request: request, completion: { result in
                switch result {
                    case .success:
                        set.collection?.notes = newNotes
                        self.currentSet = set
                        self.notifySetUpdated(set: set)
                    case .failure(let error):
                        NSLog("Error setting user notes: \(error.localizedDescription)")
                }
            })
        }
    }
    
    private func notifySetUpdated(set: SetDetail) {
        NotificationCenter.default.post(name: Notification.Name.Collection.DidUpdate, object: self, userInfo: [Notification.Key.Set: set])
    }
    
}

// =============================================================================
// MARK: - UITextFieldDelegate
// =============================================================================

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

// =============================================================================
// MARK: - UITextViewDelegate
// =============================================================================

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
