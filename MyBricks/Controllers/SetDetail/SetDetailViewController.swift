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
        case content
        case detail
        case tags
        case description
    }
    
    enum DetailRow: Int {
        case price
        case reviews
        case instructions
        case parts
        case collection
    }
    
    @IBOutlet weak var tableView: UITableView!

    var sections: [TableSection] = []
    var detailRows: [DetailRow] = []

    var isPreview: Bool = false
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
        
        // Add 'Share' button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(share(sender:)))

        setupTableView()
        
        // Keep tabs on when our collection is updated
        NotificationCenter.default.addObserver(self, selector: #selector(collectionUpdated(_:)), name: Notification.Name.Collection.DidUpdate, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSections()
        if let footerView = tableView.tableFooterView as? SetDetailFooterView, let set = self.currentSet {
            footerView.populateWithSet(set)
        }
        else {
            tableView.tableFooterView = UIView()
        }
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if setDetail == nil && !isPreview {
            fetchSetDetail()
        }
        if let set = currentSet, set.imageURL != nil && !isPreview {
            checkForLargeImage()
        }
        if additionalImages == nil && !isPreview {
            fetchAdditionalImages()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let request = self.setDetailRequest {
            request.cancel()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    // MARK: - Preview Actions
    //--------------------------------------------------------------------------
    
    override var previewActionItems: [UIPreviewActionItem] {
        var actionItems: [UIPreviewActionItem] = []
        
        if BricksetServices.isLoggedIn() {
            if let owned = currentSet?.owned, !owned {
                let action1 = UIPreviewAction(title: "I own this set", style: .default) { (_, _) in
                    if var set = self.currentSet, let setID = set.setID {
                        set.owned = true
                        set.quantityOwned = set.owned ? 1 : nil
                        
                        BricksetServices.shared.setCollectionOwns(setID: setID, owned: set.owned, completion: { result in
                            if result.isSuccess {
                                self.currentSet = set
                                self.notifySetUpdated(set: set)
                            }
                        })
                    }
                }
                actionItems.append(action1)
            }
            
            if let wanted = currentSet?.wanted, !wanted {
                let action2 = UIPreviewAction(title: "I want this set", style: .default) { (_, _) in
                    if var set = self.currentSet, let setID = set.setID {
                        set.wanted = true
                        
                        BricksetServices.shared.setCollectionWants(setID: setID, wanted: set.wanted, completion: { result in
                            if result.isSuccess {
                                self.currentSet = set
                                self.notifySetUpdated(set: set)
                            }
                        })
                    }
                }
                actionItems.append(action2)
            }
        }
        
        return actionItems
    }
    
    private func notifySetUpdated(set: Set) {
        NotificationCenter.default.post(name: Notification.Name.Collection.DidUpdate, object: self, userInfo: [Notification.Key.Set: set])
    }

    //--------------------------------------------------------------------------
    // MARK: - Collection Update Notification
    //--------------------------------------------------------------------------
    
    @objc private func collectionUpdated(_ notification: Notification) {
        if let updatedSet = notification.userInfo?[Notification.Key.Set] as? Set, updatedSet.setID == currentSet?.setID {
            self.currentSet = updatedSet
            if let detailSection = sections.index(of: .detail), let collectionRow = detailRows.index(of: .collection) {
                let indexPath = IndexPath(row: collectionRow, section: detailSection)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func setupTableView() {
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 5
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        tableView.register(SetDetailTableViewCell.self)
        tableView.register(SetPriceTableViewCell.self)
        tableView.register(SetPartsTableViewCell.self)
        tableView.register(SetReviewsTableViewCell.self)
        tableView.register(SetInstructionsTableViewCell.self)
        tableView.register(SetCollectionTableViewCell.self)
        tableView.register(SetTagsTableViewCell.self)
        tableView.register(SetDescriptionTableViewCell.self)
        
        if tableView.tableFooterView == nil {
            tableView.tableFooterView = UIView()
        }
    }
    
    private func updateSections() {
        sections.removeAll()
        detailRows.removeAll()

        // Main Content
        sections.append(.content)

        // Section for content with additional detail
        sections.append(.detail)
        detailRows.append(.price)
        if let partsCount = currentSet?.pieces, partsCount > 0 {
            detailRows.append(.parts)
        }
        if let reviewCount = currentSet?.reviewCount, reviewCount > 0 {
            detailRows.append(.reviews)
        }
        if let instructionsCount = currentSet?.instructionsCount, instructionsCount > 0 {
            detailRows.append(.instructions)
        }
        if BricksetServices.isLoggedIn() {
            detailRows.append(.collection)
        }
        
        // Tags and set description
        if let tags = setDetail?.tags, tags.count > 0 {
            sections.append(.tags)
        }
        if let detail = setDetail, let setDescription = detail.setDescription, setDescription.count > 0 {
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
                    strongSelf.updateAdditionalImages(images: images)
                }
            })
        }
    }
    
    private func updateAdditionalImages(images: [SetImage]) {
        additionalImages = images
        if let contentSection = sections.index(of: .content) {
            let indexPath = IndexPath(row: 0, section: contentSection)
            if let cell = tableView.cellForRow(at: indexPath) as? SetDetailTableViewCell {
                cell.additionalImages = images
            }
        }
    }
    
    private func checkForLargeImage() {
        if let set = currentSet, let imageURL = set.imageURL {
            let largeImageURL = imageURL.replacingOccurrences(of: "/images/", with: "/large/")
            Alamofire.request(largeImageURL, method: .head).response { response in
                if let httpResponse = response.response, httpResponse.statusCode == 200 {
                    self.hasLargeImage = true
                }
            }
        }
    }
    
    private func showImageDetail(for setImage: SetImage?) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetImagesViewController") as? SetImagesViewController {
            let mainImage = SetImage(thumbnailURL: currentSet?.thumbnailURL, imageURL: hasLargeImage ? currentSet?.largeImageURL : currentSet?.imageURL)
            let images = [mainImage]
            viewController.images = images + (additionalImages ?? [])
            viewController.selectedImage = setImage ?? mainImage
            self.present(viewController, animated: true, completion: nil)
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
        let sectionType = sections[section]
        switch sectionType {
        case .content :
            return 1
        case .detail:
            return detailRows.count
        case .tags, .description :
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let set = currentSet else { return UITableViewCell()  }

        let section = sections[indexPath.section]
        switch section {
            
        case .content :
            // "Content" section - images and primary set information
            let cell: SetDetailTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: set, additionalImages: additionalImages)
            cell.imageTapped = { image in
                self.showImageDetail(for: image)
            }
            
            return cell

        case .detail:
            // "Details" section - rows that summarize set details that can be selected to show more information
            let row = detailRows[indexPath.row]
            switch row {

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
                
            case .collection :
                let cell: SetCollectionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populate(with: set)
                return cell
                
            }
            
        case .tags :
            guard let detail = setDetail else { return UITableViewCell()  }
            let cell: SetTagsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: detail)
            cell.backgroundColor = UIColor.clear
            cell.contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            
            // Update cell width early to make sure the TagListView content size updates correctly
            cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.frame.height)
            cell.layoutIfNeeded()
            
            return cell
            
        case .description :
            guard let detail = setDetail else { return UITableViewCell()  }
            let cell: SetDescriptionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: detail)
            return cell
            
        }
        
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension SetDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let clearSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 5))
        clearSpacerView.backgroundColor = UIColor.clear
        return clearSpacerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (sections.count - 1) {
            return 5
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let height: CGFloat = (section == (sections.count - 1) ? 5 : 0)
        let clearSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: height))
        clearSpacerView.backgroundColor = UIColor.clear
        return clearSpacerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        if section == .detail {
            let row = detailRows[indexPath.row]
            switch row {
            case .price:
                if let viewController = storyboard?.instantiateViewController(withIdentifier: "PriceDetailViewController") as? PriceDetailViewController {
                    viewController.currentSet = currentSet
                    show(viewController, sender: self)
                }
                
            case .parts:
                if let viewController = storyboard?.instantiateViewController(withIdentifier: "PartsListViewController") as? PartsListViewController {
                    viewController.currentSet = currentSet
                    show(viewController, sender: self)
                }
                
            case .reviews:
                if let viewController = storyboard?.instantiateViewController(withIdentifier: "ReviewsViewController") as? ReviewsViewController {
                    viewController.currentSet = currentSet
                    show(viewController, sender: self)
                }
                
            case .instructions:
                if let viewController = storyboard?.instantiateViewController(withIdentifier: "InstructionsViewController") as? InstructionsViewController {
                    viewController.currentSet = currentSet
                    show(viewController, sender: self)
                }
                
            case .collection:
                if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionDetailViewController") as? CollectionDetailViewController {
                    viewController.currentSet = currentSet
                    show(viewController, sender: self)
                }
                
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
