//
//  SetHeroImageTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetHeroImageTableViewCell: UITableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var zoomButton: UIButton!
    
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
    }

    //--------------------------------------------------------------------------
    // MARK: - Layout
    //--------------------------------------------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.frame.size
        }
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

    func populate(with set: Set, additionalImages: [SetImage]?) {
        mainImageURL = set.largeThumbnailURL
        if let images = additionalImages {
            self.additionalImages = images
            collectionView.reloadData()
        }
    }

    func showZoomButton(animated: Bool) {
        zoomButton.alpha = 0.0
        zoomButton.isHidden = false
        let animations = { () -> Void in
            self.zoomButton.alpha = 1.0
        }
        let completion = { (finished: Bool) -> Void in
        }
        UIView.animate(withDuration: animated ? 0.25 : 0.0, animations:animations, completion: completion)
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

extension SetHeroImageTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.additionalImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SetImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        if indexPath.item == 0 {
            if let urlString = mainImageURL, let thumbnailURL = URL(string: urlString) {
                cell.imageView.af_setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3))
            }
        }
        else {
            let image = self.additionalImages[indexPath.item-1]
            if let thumbnailURLString = image.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
                cell.imageView.af_setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3))
            }
        }
        return cell
    }
}

//==============================================================================
// MARK: - UICollectionViewDelegate
//==============================================================================

extension SetHeroImageTableViewCell: UICollectionViewDelegate {
    
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
// MARK: - UIScrollViewDelegate
//==============================================================================

extension SetHeroImageTableViewCell: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let itemIndex = collectionView.indexPathForItem(at: targetContentOffset.pointee)?.item {
            self.currentPage = itemIndex
            updatePageIndicater()
        }
    }

}
