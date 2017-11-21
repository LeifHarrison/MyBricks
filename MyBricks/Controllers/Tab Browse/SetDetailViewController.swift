//
//  SetDetailViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/19/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

enum TableSection: Int {
    case image, detail, reviews, instructions, parts, collection, barcodes
}

class SetDetailViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var sections: [TableSection] = [ .image, .detail, .parts ]

    var currentSet : Set?
    var detailSet : SetDetail?
    var currentSetImage : UIImage?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = currentSet?.fullSetNumber

        if let reviewCount = currentSet?.reviewCount, reviewCount > 0 {
            sections.append(.reviews)
        }
        if let instructionsCount = currentSet?.instructionsCount, instructionsCount > 0 {
            sections.append(.instructions)
        }

        if BricksetServices.isLoggedIn() {
            sections.append(.collection)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let set = currentSet, let setID = set.setID {
            BricksetServices.shared.getSet(setID: setID, completion: { result in
                self.detailSet = result.value
                //print("Result \(String(describing: self.detailSet))")
            })
        }

    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

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
        
        guard let set = currentSet else {
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

            case .collection :
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SetCollectionTableViewCell", for: indexPath) as? SetCollectionTableViewCell {
                    cell.ownedCheckboxButton.isSelected = set.owned ?? false
                    cell.wantedCheckboxButton.isSelected = set.wanted ?? false
                    cell.ownedCountField.text = "\(set.quantityOwned ?? 0)"

                    cell.yourRatingView.didFinishTouchingCosmos = { rating in
                        print("rating = \(rating)")
                    }

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
            case .image         : return 260.0
            case .detail        : return 260.0
            case .collection    : return 280.0
            case .parts         : return 280.0
            case .reviews       : return 280.0
            case .instructions  : return 280.0
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
