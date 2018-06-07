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
        smallCollectionView.addBorder()
        smallCollectionView.register(SetImageCollectionViewCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if selectedImage == nil {
            selectedImage = images.first
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentImage = selectedImage {
            let indexPath = IndexPath(item: images.index(of: currentImage) ?? 0, section: 0)
            largeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            smallCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Layout
    //--------------------------------------------------------------------------
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = largeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = largeCollectionView.frame.size
            layout.invalidateLayout()
            largeCollectionView.reloadData()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func close(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
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
            
            cell.imageView.contentMode = .center
            cell.imageView.image = #imageLiteral(resourceName: "placeholder1")

            if let thumbnailURLString = image.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
                cell.imageView.af_setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3)) { response in
                    if response.result.value != nil {
                        cell.imageView.contentMode = .scaleAspectFit
                    }
                }
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
        if collectionView == smallCollectionView {
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == largeCollectionView && decelerate {
            if let indexPath = self.largeCollectionView.indexPathsForVisibleItems.first {
                self.smallCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == largeCollectionView {
            // This, along with the scrollToItem above seems to fix an issue where sometimes the
            // selection wouldn't "take" when scrolling through several items rapidly in succession
            // (from the large image collection view)
            let tinyDelay = DispatchTime.now() + Double(Int64(0.01 * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: tinyDelay, execute: {
                if let indexPath = self.largeCollectionView.indexPathsForVisibleItems.first {
                    self.smallCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                }
            })
        }
    }
    
}
