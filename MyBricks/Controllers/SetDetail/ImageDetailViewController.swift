//
//  ImageDetailViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/2/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    let defaultInsets: CGFloat = 20.0
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!

    public var imageURL: String? = nil
    
    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentInset = UIEdgeInsets(top: defaultInsets, left: defaultInsets, bottom: defaultInsets, right: defaultInsets)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        imageView.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let urlString = imageURL, let url = URL(string: urlString) {
            activityIndicator.startAnimating()
            imageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.3)) { response in
                self.activityIndicator.stopAnimating()
                if let image = response.result.value {
                    let horizontalZoom = (image.size.width + self.defaultInsets * 4) / self.scrollView.frame.size.width
                    let verticalZoom = (image.size.height + self.defaultInsets * 4) / self.scrollView.frame.size.height
                    self.scrollView.minimumZoomScale = 1 / max(horizontalZoom, verticalZoom)
                    self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
                }
            }
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
// MARK: - UIScrollViewDelegate
//==============================================================================

extension ImageDetailViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

