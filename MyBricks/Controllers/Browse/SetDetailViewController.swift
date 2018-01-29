//
//  SetDetailViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/19/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Alamofire

class SetDetailViewController: UIViewController {

    enum TableSection: Int {
        case image
        case detail
        case reviews
        case instructions
        case parts
        case collection
        case description
        case barcodes
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var sections: [TableSection] = [ .image, .detail, .parts ]

    var currentSet: Set?
    var setDetail: SetDetail?
    var currentSetImage: UIImage?
    
    var setDetailRequest: DataRequest? = nil

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        addGradientBackground()

        hideKeyboardWhenViewTapped()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.separatorColor = UIColor(white: 0.3, alpha: 0.8)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = currentSet?.fullSetNumber

        sections = [ .image, .detail, .parts ]
        if let reviewCount = currentSet?.reviewCount, reviewCount > 0 {
            sections.append(.reviews)
        }
        if let instructionsCount = currentSet?.instructionsCount, instructionsCount > 0 {
            sections.append(.instructions)
        }
        if BricksetServices.isLoggedIn() {
            sections.append(.collection)
        }
        if setDetail != nil {
            sections.append(.description)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(with:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if setDetail == nil {
            fetchSetDetail()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        if let request = self.setDetailRequest {
            request.cancel()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        super.viewDidDisappear(animated)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func fetchSetDetail() {
        if let set = currentSet, let setID = set.setID {
            setDetailRequest = BricksetServices.shared.getSet(setID: setID, completion: { [weak self] result in
                self?.setDetailRequest = nil
                if result.isSuccess, let detail = result.value {
                    self?.setDetail = detail
                    if let setDescription = detail.setDescription, setDescription.count > 0 {
                        self?.sections.append(.description)
                        if let index = self?.sections.index(of: .description) {
                            self?.tableView.insertSections([index], with: .fade)
                        }
                    }
                }
            })
        }
    }
    
    @objc private func keyboardWillShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        var contentInset = self.tableView.contentInset
        contentInset.bottom += keyboardFrame.height
        
        self.tableView.contentInset = contentInset
        self.tableView.scrollIndicatorInsets = contentInset

        if let section = sections.index(of: .collection) {
            let indexPath = IndexPath(row: 0, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(with notification: Notification) {
        var contentInset = self.tableView.contentInset
        contentInset.bottom = 0
        
        self.tableView.contentInset = contentInset
        self.tableView.scrollIndicatorInsets = contentInset
    }
}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension SetDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("cellForRowAt: \(indexPath)")
        
        guard var set = currentSet else {
            return UITableViewCell()
        }

        let section = sections[indexPath.section]
        switch section {

            case .image :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetImageTableViewCell", for: indexPath) as? SetImageTableViewCell {
                    cell.populateWithSet(set)

                    // Populate the image ourselves, so we can reload the cell when the image finishes loading
                    if let image = currentSetImage {
                        cell.setImageView.image = image
                    }
                    else if let urlString = set.imageURL, let url = URL(string: urlString) {
                        cell.setImageView?.af_setImage(withURL: url) { response in
                            if let image = response.result.value {
                                print("image size: \(image.size)")
                                self.currentSetImage = image
                                DispatchQueue.main.async(execute: {
                                    tableView.reloadRows(at: [indexPath], with: .fade)
                                })
                            }
                        }
                    }

                    return cell
                }


            case .detail :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetDetailTableViewCell", for: indexPath) as? SetDetailTableViewCell {
                    cell.populateWithSet(set)
                    return cell
                }

            case .parts :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetPartsTableViewCell", for: indexPath) as? SetPartsTableViewCell {
                    cell.populateWithSet(set)
                    return cell
                }

            case .reviews :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetReviewsTableViewCell", for: indexPath) as? SetReviewsTableViewCell {
                    cell.populateWithSet(set)
                    return cell
                }
            
            case .instructions :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SetInstructionsTableViewCell", for: indexPath)
                cell.textLabel?.text = "Instructions (\(set.instructionsCount ?? 0))"
                return cell
            
            case .collection :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetCollectionTableViewCell", for: indexPath) as? SetCollectionTableViewCell {
                    cell.ownedCheckboxButton.isSelected = set.owned ?? false
                    cell.wantedCheckboxButton.isSelected = set.wanted ?? false
                    cell.ownedCountField.text = "\(set.quantityOwned ?? 0)"
                    //cell.yourRatingView.rating = set.youRating
                    cell.notesTextView.text = set.userNotes
                    
                    cell.yourRatingView.didFinishTouchingCosmos = { rating in
                        print("rating = \(rating)")
                    }
                    cell.toggleSetOwned = {
                        print("toggleSetOwned")
                        if let setID = set.setID, let owned = set.owned {
                            BricksetServices.shared.setCollectionOwns(setID: setID, owned: !owned, completion: { result in
                                if result.isSuccess {
                                    set.owned = !owned
                                    set.quantityOwned = !owned ? 1 : nil
                                    cell.populateWithSet(set)
                                }
                            })
                        }
                    }
                    cell.toggleSetWanted = {
                        print("toggleSetWanted")
                        if let setID = set.setID, let wanted = set.wanted {
                            BricksetServices.shared.setCollectionWants(setID: setID, wanted: !wanted, completion: { result in
                                if result.isSuccess {
                                    set.wanted = !wanted
                                    cell.populateWithSet(set)
                                }
                            })
                        }
                    }
                    cell.updateQuantityOwned = { newQuantity in
                        print("updateQuantityOwned")
                        if let setID = set.setID {
                            BricksetServices.shared.setCollectionQuantityOwned(setID: setID, quantityOwned: newQuantity, completion: { result in
                                if result.isSuccess {
                                    set.owned = (newQuantity > 0) ? true : false
                                    set.quantityOwned = newQuantity
                                    cell.populateWithSet(set)
                                }
                            })
                        }
                    }
                    cell.updateUserNotes = { newNotes in
                        print("updateUserNotes")
                        if let setID = set.setID {
                            BricksetServices.shared.setCollectionUserNotes(setID: setID, notes: newNotes, completion: { result in
                                if result.isSuccess {
                                    set.userNotes = newNotes
                                    cell.populateWithSet(set)
                                }
                            })
                        }

                    }

                    return cell
                }
            
            case .description :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetDescriptionTableViewCell", for: indexPath) as? SetDescriptionTableViewCell {
                    if let detail = setDetail {
                        cell.populate(with: detail)
                    }
                    return cell
                }
            
            default :
                return UITableViewCell()

        }

        return UITableViewCell()
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension SetDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        switch section {
            case .image         : return 240.0
            case .detail        : return 180.0
            case .collection    : return 280.0
            case .parts         : return 44.0
            case .reviews       : return 44.0
            case .instructions  : return 44.0
            case .description   : return 140.0
            default             : return 30.0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //print("willDisplay: \(cell), forRowAt: \(indexPath)")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]

        if section == .reviews {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewsViewController") as? ReviewsViewController {
                vc.currentSet = currentSet
                show(vc, sender: self)
            }
        }
        if section == .instructions {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "InstructionsViewController") as? InstructionsViewController {
                vc.currentSet = currentSet
                show(vc, sender: self)
            }
        }
        if section == .parts {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PartsListViewController") as? PartsListViewController {
                vc.currentSet = currentSet
                show(vc, sender: self)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white
        }
    }

}
