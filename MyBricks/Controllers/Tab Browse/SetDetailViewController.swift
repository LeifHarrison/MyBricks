//
//  SetDetailViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/19/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

enum TableSection: Int {
    case image = 0, detail, pricing, rating, availability, collection, notes, barcodes
}

class SetDetailViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    let sections: [TableSection] = [ .image, .detail, .pricing, .rating, .collection, .notes ]

    var currentSet : Set?
    var currentSetImage : UIImage?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "SetDetailImageTableViewCell", bundle: nil), forCellReuseIdentifier: "SetDetailImageTableViewCell")
        tableView.register(UINib(nibName: "SetDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "SetDetailTableViewCell")
        tableView.register(UINib(nibName: "SetDetailPricingTableViewCell", bundle: nil), forCellReuseIdentifier: "SetDetailPricingTableViewCell")
        tableView.register(UINib(nibName: "SetDetailRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "SetDetailRatingTableViewCell")
        tableView.register(UINib(nibName: "SetDetailCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SetDetailCollectionTableViewCell")
        tableView.register(UINib(nibName: "SetDetailNotesTableViewCell", bundle: nil), forCellReuseIdentifier: "SetDetailNotesTableViewCell")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

        guard let set = currentSet else {
            return UITableViewCell()
        }

        let section = sections[indexPath.section]
        switch section {
            case .image :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetDetailImageTableViewCell", for: indexPath) as? SetDetailImageTableViewCell {
                    if let image = currentSetImage {
                        cell.setImageView.image = image
                    }
                    else if let urlString = set.imageURL, let url = URL(string: urlString) {
                        cell.setImageView?.af_setImage(withURL: url) { response in
                            if let image = response.result.value {
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
                    cell.populateWithSet(set: set)
                    return cell
                }
            case .pricing :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetDetailPricingTableViewCell", for: indexPath) as? SetDetailPricingTableViewCell {
                    cell.populateWithSet(set: set)
                    return cell
                }
            case .rating :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetDetailRatingTableViewCell", for: indexPath) as? SetDetailRatingTableViewCell {
                    cell.populateWithSet(set: set)
                    return cell
                }
            case .collection :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetDetailCollectionTableViewCell", for: indexPath) as? SetDetailCollectionTableViewCell {
                    cell.ownedCheckboxButton.isSelected = set.owned ?? false
                    cell.wantedCheckboxButton.isSelected = set.wanted ?? false
                    cell.ownedCountField.text = "\(set.quantityOwned ?? 0)"

                    return cell
                }
            case .notes :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetDetailNotesTableViewCell", for: indexPath) as? SetDetailNotesTableViewCell {
                    cell.notesTextView.text = set.userNotes
                    return cell
                }
            default :
                return UITableViewCell()

        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        switch section {
            case .image :       return nil // No header for the set image
            case .detail :      return "SET DETAIL"
            case .pricing :     return "PRICING"
            case .rating :      return "RATING"
            case .collection :  return "COLLECTION"
            case .notes :       return "YOUR NOTES"
            default :           return nil

        }
    }
}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension SetDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        switch section {
            case .image :       return 250.0
            case .detail :      return 360.0
            case .pricing :     return 90.0
            case .rating :      return 100.0
            case .collection :  return 90.0
            case .notes :       return 150.0
            default :           return 0.0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did Select Row")
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(red: ( 6 / 255 ), green: ( 144 / 255 ), blue: ( 214 / 255 ), alpha: 1.0)
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white
        }
    }

}

//==============================================================================
// MARK: - SetDetailTableViewCell extension
//==============================================================================

extension SetDetailTableViewCell {

    func populateWithSet(set : Set) -> Void {
        setNameField.text = set.name
        setNumberField.text = set.number
        setTypeField.text = "-"
        themeGroupField.text = set.themeGroup
        themeField.text = set.theme
        yearReleasedField.text = set.year
        tagsField.text = "-"
        piecesField.text = "\(set.pieces ?? 0)"
        minifiguresField.text = "\(set.minifigs ?? 0)"
        ageRangeField.text = "-"
        packagingField.text = set.packagingType
        weightField.text = "-"
        availabilityField.text = set.availability
    }
}

//==============================================================================
// MARK: - SetDetailPricingTableViewCell extension
//==============================================================================

extension SetDetailPricingTableViewCell {

    func populateWithSet(set : Set) -> Void {
        retailPriceField.text = "🇺🇸 $\(set.retailPriceUS ?? "-") | 🇨🇦 $\(set.retailPriceCA ?? "-") | 🇬🇧 £\(set.retailPriceUK ?? "-") | 🇪🇺 €\(set.retailPriceEU ?? "-")"
        currentValueField.text = "-"
        pricePerPieceField.text = "-"
    }
}

//==============================================================================
// MARK: - SetDetailRatingTableViewCell extension
//==============================================================================

extension SetDetailRatingTableViewCell {

    func populateWithSet(set : Set) -> Void {
        setRatingView.rating = set.rating ?? 0
        setRatingView.text = "(\(set.rating ?? 0))"
        if let reviewCount = set.reviewCount {
            reviewsField.text = "from \(reviewCount) reviews"
        }
        yourRatingView.didFinishTouchingCosmos = { rating in
            print("rating = \(rating)")
        }

    }
}

