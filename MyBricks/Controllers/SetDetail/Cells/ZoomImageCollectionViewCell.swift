//
//  ZoomImageCollectionViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 5/17/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class ZoomImageCollectionViewCell: UICollectionViewCell, ReusableView, NibLoadableView {

    let defaultInsets: CGFloat = 20.0

    @IBOutlet weak var activityIndicatorView: ActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = #imageLiteral(resourceName: "placeholder2Large")
        imageView.sizeToFit()
        scrollView.contentSize = self.imageView.frame.size
        updateZoomScales()
        updateImageViewConstraints()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Layout
    //--------------------------------------------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateZoomScales()
        updateImageViewConstraints()
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with setImage: SetImage) {
        if let imageURLString = setImage.imageURL, let imageURL = URL(string: imageURLString) {
            activityIndicatorView.startAnimating()
            imageView.af_setImage(withURL: imageURL, placeholderImage: #imageLiteral(resourceName: "placeholder2Large"), imageTransition: .crossDissolve(0.3)) { response in
                self.activityIndicatorView.stopAnimating()
                if response.value != nil {
                    self.imageView.sizeToFit()
                    self.scrollView.contentSize = self.imageView.frame.size
                }
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func updateZoomScales() {
        if imageView.bounds.width > 0, imageView.bounds.height > 0 {
            let widthScale = scrollView.frame.size.width / (imageView.bounds.width + 5*defaultInsets)
            let heightScale = scrollView.frame.size.height / (imageView.bounds.height + 5*defaultInsets)
            let minScale = min(widthScale, heightScale)
            
            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = 3.0
            scrollView.zoomScale = minScale
        }
    }
    
    fileprivate func updateImageViewConstraints() {
        let yOffset = max(0, (scrollView.frame.size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (scrollView.frame.size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
    }
    
}

//==============================================================================
// MARK: - UIScrollViewDelegate
//==============================================================================

extension ZoomImageCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageViewConstraints()
        scrollView.isScrollEnabled = scrollView.zoomScale > (scrollView.minimumZoomScale + 0.0000001)
    }
    
}
