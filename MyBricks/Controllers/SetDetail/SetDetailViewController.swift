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

    enum TableSectionType: Int {
        case heroImage
        case detail
        case price
        case reviews
        case instructions
        case parts
        case tags
        case collection
        case description
        case barcodes
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var sections: [TableSectionType] = []

    var currentSet: Set?
    var setDetail: SetDetail?
    var additionalImages: [SetImage]?
    var currentSetImage: UIImage?
    var hasLargeImage: Bool = false
    
    var setDetailRequest: DataRequest?
    var additionalImagesRequest: DataRequest?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Set Detail", comment: "")
        
        hideKeyboardWhenViewTapped()
        
        // Add 'Share' button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(sender:)))

        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(with:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name: .UIKeyboardWillHide, object: nil)
        
        updateSections()
        if let footerView = tableView.tableFooterView as? SetDetailFooterView, let set = self.currentSet {
            footerView.populateWithSet(set)
        }
        else {
            tableView.tableFooterView = UIView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if setDetail == nil {
            fetchSetDetail()
        }
        if additionalImages == nil {
            fetchAdditionalImages()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)

        if let request = self.setDetailRequest {
            request.cancel()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func share(sender: UIButton) {
        if let urlString = currentSet?.bricksetURL, let url = NSURL(string: urlString) {
            let objectsToShare = [url] as [Any]
            let safariActivity = SafariActivity()
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [safariActivity])
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(SetCollectionTableViewCell.self)
        tableView.register(SetDetailTableViewCell.self)
        tableView.register(SetHeroImageTableViewCell.self)
        tableView.register(SetImagesTableViewCell.self)
        tableView.register(SetPartsTableViewCell.self)
        tableView.register(SetPriceTableViewCell.self)
        tableView.register(SetReviewsTableViewCell.self)
        tableView.register(SetInstructionsTableViewCell.self)
        tableView.register(SetTagsTableViewCell.self)
        tableView.register(SetDescriptionTableViewCell.self)
        
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = UIView()
        }
    }
    
    private func updateSections() {
        sections.removeAll()
        
        sections.append(.heroImage)
        sections.append(.detail)
        sections.append(.price)
        sections.append(.parts)
        if let reviewCount = currentSet?.reviewCount, reviewCount > 0 {
            sections.append(.reviews)
        }
        if let instructionsCount = currentSet?.instructionsCount, instructionsCount > 0 {
            sections.append(.instructions)
        }
        if BricksetServices.isLoggedIn() {
            sections.append(.collection)
        }
        if let tags = setDetail?.tags, tags.count > 0 {
            sections.append(.tags)
        }
        if setDetail != nil {
            sections.append(.description)
        }
    }
    
    private func fetchSetDetail() {
        if let set = currentSet, let setID = set.setID {
            setDetailRequest = BricksetServices.shared.getSet(setID: setID, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                
                strongSelf.setDetailRequest = nil
                
                if result.isSuccess, let detail = result.value {
                    strongSelf.setDetail = detail
                    
                    strongSelf.tableView.beginUpdates()
                    strongSelf.updateSections()
                    if let index = strongSelf.sections.index(of: .tags) {
                        strongSelf.tableView.insertSections([index], with: .fade)
                    }
                    if let index = strongSelf.sections.index(of: .description) {
                        strongSelf.tableView.insertSections([index], with: .fade)
                    }
                    strongSelf.tableView.endUpdates()
                }
            })
        }
    }
    
    private func fetchAdditionalImages() {
        if let set = currentSet, let setID = set.setID {
            additionalImagesRequest = BricksetServices.shared.getAdditionalImages(setID: setID, completion: { [weak self] result in
                guard let strongSelf = self else { return }

                strongSelf.additionalImagesRequest = nil
                if result.isSuccess, let images = result.value, images.count > 0 {
                    strongSelf.additionalImages = images
                    if let imageSectionIndex = strongSelf.sections.index(of: .heroImage) {
                        strongSelf.tableView.reloadSections([imageSectionIndex], with: .fade)
                    }
                }
            })
        }
    }
    
    private func showLargeImage() {
        performSegue(withIdentifier: "showImageDetailView", sender: self)
    }
    
    private func showImageDetail(for setImage: SetImage?) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController {
            if let selectedImage = setImage {
                viewController.imageURL = selectedImage.imageURL
            }
            else if let set = self.currentSet, let imageURL = set.imageURL {
                if self.hasLargeImage {
                    let largeImageURL = imageURL.replacingOccurrences(of: "/images/", with: "/large/")
                    viewController.imageURL = largeImageURL
                }
                else {
                    viewController.imageURL = imageURL
                }
            }
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Keyboard Notifications
    //--------------------------------------------------------------------------
    
    @objc private func keyboardWillShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        var contentInset = self.tableView.contentInset
        contentInset.bottom += keyboardFrame.height
        if let tabController = self.tabBarController {
            contentInset.bottom -= tabController.tabBar.frame.height
        }

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
    
    //--------------------------------------------------------------------------
    // MARK: - Storyboards and Segues
    //--------------------------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageVC = segue.destination as? ImageDetailViewController {
            if let set = currentSet, let imageURL = set.imageURL {
                let largeImageURL = imageURL.replacingOccurrences(of: "/images/", with: "/large/")
                imageVC.imageURL = largeImageURL
            }
        }
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
        guard let set = currentSet else { return UITableViewCell()  }

        let section = sections[indexPath.section]
        switch section {
            
        case .heroImage :
            let cell: SetHeroImageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set, additionalImages: additionalImages)

            cell.imageTapped = { image in
                self.showImageDetail(for: image)
            }

            return cell
            
        case .detail :
            let cell: SetDetailTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set)
            return cell

        case .price :
            let cell: SetPriceTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set)
            return cell

        case .parts :
            let cell: SetPartsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set)
            return cell

        case .reviews :
            let cell: SetReviewsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set)
            return cell
            
        case .instructions :
            let cell: SetInstructionsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set)
            return cell
            
        case .tags :
            guard let detail = setDetail else { return UITableViewCell()  }

            let cell: SetTagsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: detail)
            
            // Update cell width early to make sure the TagListView content size updates correctly
            cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.frame.height)
            cell.layoutIfNeeded()
            
            return cell

        case .collection :
            let cell: SetCollectionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set)
            
            cell.setUpdated = { set in
                self.currentSet = set
            }
            
            return cell

        case .description :
            guard let detail = setDetail else { return UITableViewCell()  }

            let cell: SetDescriptionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: detail)
            return cell

        default :
            return UITableViewCell()
            
        }
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension SetDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]

        if section == .price {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "PriceDetailViewController") as? PriceDetailViewController {
                viewController.currentSet = currentSet
                show(viewController, sender: self)
            }
        }
        if section == .parts {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "PartsListViewController") as? PartsListViewController {
                viewController.currentSet = currentSet
                show(viewController, sender: self)
            }
        }
        if section == .reviews {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "ReviewsViewController") as? ReviewsViewController {
                viewController.currentSet = currentSet
                show(viewController, sender: self)
            }
        }
        if section == .instructions {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "InstructionsViewController") as? InstructionsViewController {
                viewController.currentSet = currentSet
                show(viewController, sender: self)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
