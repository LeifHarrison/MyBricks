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
    
    enum ContentRow: Int {
        case images
        case detail
    }
    
    enum DetailRow: Int {
        case price
        case reviews
        case instructions
        case parts
        case collection
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var sections: [TableSection] = []
    var contentRows: [ContentRow] = []
    var detailRows: [DetailRow] = []

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
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(share(sender:)))

        setupTableView()
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if setDetail == nil {
            fetchSetDetail()
        }
        if let set = currentSet, set.imageURL != nil {
            checkForLargeImage()
        }
        if additionalImages == nil {
            fetchAdditionalImages()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 5
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
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
        contentRows.removeAll()
        detailRows.removeAll()

        // Main Content
        sections.append(.content)
        contentRows.append(.images)
        contentRows.append(.detail)

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
        // TODO: Disable image collection view selection while attempting to load additional images
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
        if let contentSection = sections.index(of: .content), let imagesRow = contentRows.index(of: .images) {
            let indexPath = IndexPath(row: imagesRow, section: contentSection)
            if let cell = tableView.cellForRow(at: indexPath) as? SetHeroImageTableViewCell {
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
            return contentRows.count
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
        
            // "Content" section - images and primary set information
            
        case .content :
            let row = contentRows[indexPath.row]
            switch row {
            case .images:
                let cell: SetHeroImageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populate(with: set, additionalImages: additionalImages)
                
                cell.imageTapped = { image in
                    self.showImageDetail(for: image)
                }
                
                return cell

            case .detail :
                let cell: SetDetailTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.populate(with: set)
                cell.indentationLevel = 1
                cell.indentationWidth = 10
                return cell
                
            }
            
            // "Details" section - rows that summarize set details that can be selected to show more information
            
        case .detail:
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
