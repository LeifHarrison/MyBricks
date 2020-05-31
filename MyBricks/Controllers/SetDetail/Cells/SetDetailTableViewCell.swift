//
//  SetDetailTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/24/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailTableViewCell: BlueGradientTableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageLabel: UILabel!

    @IBOutlet weak var setNameField: UILabel!
    @IBOutlet weak var setNumberField: UILabel!
    @IBOutlet weak var themeGroupField: UILabel!
    @IBOutlet weak var themeField: UILabel!
    @IBOutlet weak var availabilityField: UILabel!

    var mainImageURL: String?
    var imageTapped: ((SetImage?) -> Void)?
    
    var currentPage: Int = 0 {
        didSet {
            updatePageIndicater()
        }
    }
    
    var additionalImages: [SetImage] = [] {
        didSet {
            if additionalImages.count > 0 {
                showPageControls(animated: true)
                updatePageIndicater()
                collectionView.reloadData()
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset =  CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 1
        
        collectionView.register(SetImageCollectionViewCell.self)
        
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()

        pageLabel.text = nil
        
        nextButton.isHidden = true
        previousButton.isHidden = true
        pageControl.isHidden = true
        pageLabel.isHidden = true
        
        setNameField.text = nil
        setNumberField.text = nil
        themeField.text = nil
        themeGroupField.text = nil
        availabilityField.text = nil
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func next(_ sender: UIButton) {
        setCurrentPage(page: currentPage+1)
    }
    
    @IBAction func previous(_ sender: UIButton) {
        setCurrentPage(page: currentPage-1)
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        setCurrentPage(page: pageControl.currentPage)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with set: SetDetail, additionalImages: [SetImage]?) {
        mainImageURL = set.image?.imageURL
        if let images = additionalImages {
            self.additionalImages = images
            //collectionView.reloadData()
        }

        setNameField.text = set.name
        setNumberField.text = set.setNumberAgeYearDescription
        themeField.text = set.themeDescription()
        themeGroupField.text = set.categoryAndGroupDescription()
        availabilityField.text = set.availabilityDescription()
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func showPageControls(animated: Bool) {
        let pageIndicator: UIView = (self.additionalImages.count + 1) > 15 ? pageLabel : pageControl
        
        nextButton.alpha = 0.0
        previousButton.alpha = 0.0
        pageIndicator.alpha = 0.0
        
        nextButton.isHidden = false
        previousButton.isHidden = false
        pageIndicator.isHidden = false
        
        let animations = { () -> Void in
            self.nextButton.alpha = 1.0
            self.previousButton.alpha = 1.0
            pageIndicator.alpha = 1.0
        }
        let completion: ((Bool) -> Void) = { finished in
        }
        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations:animations, completion: completion)
    }
    
    private func updatePageIndicater() {
        let numberOfPages = additionalImages.count + 1
        if !pageControl.isHidden {
            pageControl.currentPage = currentPage
            pageControl.numberOfPages = numberOfPages
        }
        if !pageLabel.isHidden {
            pageLabel.text = String(format: "%d of %d", currentPage+1, numberOfPages)
        }
        
        nextButton.isEnabled = (numberOfPages > 1) && (currentPage < numberOfPages - 1)
        previousButton.isEnabled = (numberOfPages > 1) && (currentPage > 0)
    }
    
    private func setCurrentPage(page: Int) {
        self.currentPage = page
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

}

//==============================================================================
// MARK: - UICollectionViewDataSource
//==============================================================================

extension SetDetailTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.additionalImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SetImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        cell.imageView.contentMode = .center
        cell.imageView.image = #imageLiteral(resourceName: "placeholder2Large")

        if indexPath.item == 0 {
            if let urlString = mainImageURL, let thumbnailURL = URL(string: urlString) {
                cell.imageView.af.setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3)) { response in
                    if response.value != nil {
                        cell.imageView.contentMode = .scaleAspectFit
                    }
                }
            }
        }
        else {
            let image = self.additionalImages[indexPath.item-1]
            if let thumbnailURLString = image.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
                cell.imageView.af.setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3)) { response in
                    if response.value != nil {
                        cell.imageView.contentMode = .scaleAspectFit
                    }
                }
            }
        }
        return cell
    }
}

//==============================================================================
// MARK: - UICollectionViewDelegate
//==============================================================================

extension SetDetailTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            imageTapped?(nil)
        }
        else {
            let image = self.additionalImages[indexPath.item-1]
            imageTapped?(image)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

//==============================================================================
// MARK: - UICollectionViewDelegateFlowLayout
//==============================================================================

extension SetDetailTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

}

//==============================================================================
// MARK: - UIScrollViewDelegate
//==============================================================================

extension SetDetailTableViewCell: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let itemIndex = collectionView.indexPathForItem(at: targetContentOffset.pointee)?.item {
            self.currentPage = itemIndex
            updatePageIndicater()
        }
    }
    
}
