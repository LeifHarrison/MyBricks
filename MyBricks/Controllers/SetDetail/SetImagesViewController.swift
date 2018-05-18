//
//  SetImagesViewController.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/15/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetImagesViewController: UIViewController {

    @IBOutlet weak var largeCollectionView: UICollectionView!
    @IBOutlet weak var smallCollectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!

    var images: [SetImage] = []
    var selectedImage: SetImage?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        largeCollectionView.register(ZoomImageCollectionViewCell.self)
        if let layout = largeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = largeCollectionView.frame.size
        }

        smallCollectionView.addBorder()
        smallCollectionView.register(SetImageCollectionViewCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedImage == nil {
            selectedImage = images.first
        }
        guard let currentImage = selectedImage else { return }
        let indexPath = IndexPath(item: images.index(of: currentImage) ?? 0, section: 0)
        largeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        smallCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func close(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func updateCurrentPage() {
        
    }
}

//==============================================================================
// MARK: - UICollectionViewDataSource
//==============================================================================

extension SetImagesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = self.images[indexPath.item]
        if collectionView == largeCollectionView {
            let cell: ZoomImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            cell.populate(with: image)
            return cell
        }
        else if collectionView == smallCollectionView {
            let cell: SetImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            if let thumbnailURLString = image.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
                cell.imageView.af_setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3))
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
}

//==============================================================================
// MARK: - UICollectionViewDelegate
//==============================================================================

extension SetImagesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == largeCollectionView {
        }
        else if collectionView == smallCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.isSelected = true
            }
            largeCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            smallCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}

//==============================================================================
// MARK: - UIScrollViewDelegate
//==============================================================================

extension SetImagesViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == largeCollectionView {
            if let indexPath = largeCollectionView.indexPathsForVisibleItems.first {
                smallCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
}
