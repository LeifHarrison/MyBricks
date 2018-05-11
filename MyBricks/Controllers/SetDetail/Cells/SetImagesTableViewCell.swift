//
//  SetImagesTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/2/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetImagesTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [SetImage] = []
    var imageTapped: ((SetImage) -> Void)?

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        collectionView.register(SetImageCollectionViewCell.self)
        prepareForReuse()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.images.removeAll()
        self.imageTapped = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with setImages: [SetImage]) {
        self.images = setImages
        collectionView.reloadData()
    }
    
}

//==============================================================================
// MARK: - UICollectionViewDataSource
//==============================================================================

extension SetImagesTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SetImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let image = self.images[indexPath.item]
        if let thumbnailURLString = image.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
            cell.imageView.af_setImage(withURL: thumbnailURL, imageTransition: .crossDissolve(0.3))
        }
        return cell
    }
}

//==============================================================================
// MARK: - UICollectionViewDelegate
//==============================================================================

extension SetImagesTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = self.images[indexPath.item]
        imageTapped?(image)
    }
    
}
