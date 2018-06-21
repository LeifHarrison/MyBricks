//
//  BarcodeScannerViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/13/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
	
    private let regionOfInterestCornerRadius: CGFloat = 4.0
    private let regionOfInterestWidthScale: CGFloat = 0.8
    private let regionOfInterestHeightScale: CGFloat = 0.25

    private let maskLayer = CAShapeLayer()
    private let maskAlpha: Float = 0.4
    private let regionOfInterestOutline = CAShapeLayer()
    private let outlineAlpha: CGFloat = 0.8

    var regionOfInterest = CGRect.null

    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

		maskLayer.fillRule = kCAFillRuleEvenOdd
		maskLayer.fillColor = UIColor.black.cgColor
		maskLayer.opacity = maskAlpha
		layer.addSublayer(maskLayer)
		
        let width = regionOfInterestWidthScale * bounds.width
        let height = regionOfInterestHeightScale * bounds.height
        let regionX = (bounds.width - width) / 2.0
        let regionY = (bounds.height - height) / 2.0
        regionOfInterest = CGRect(x: regionX, y: regionY, width: width, height: height)

        regionOfInterestOutline.fillColor = UIColor.clear.cgColor
        regionOfInterestOutline.lineWidth = 2.0
        regionOfInterestOutline.path = UIBezierPath(roundedRect: regionOfInterest, cornerRadius: regionOfInterestCornerRadius).cgPath
        regionOfInterestOutline.strokeColor = UIColor(white: 1.0, alpha: outlineAlpha).cgColor
		layer.addSublayer(regionOfInterestOutline)
	}
	
    //--------------------------------------------------------------------------
	// MARK: AV capture properties
    //--------------------------------------------------------------------------

	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
		guard let layer = layer as? AVCaptureVideoPreviewLayer else {
			fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
		}
		
		return layer
	}
	
	var session: AVCaptureSession? {
		get {
			return videoPreviewLayer.session
		}
		set {
			videoPreviewLayer.session = newValue
		}
	}
	
    //--------------------------------------------------------------------------
	// MARK: UIView
    //--------------------------------------------------------------------------

    override class var layerClass: AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		// Disable CoreAnimation actions so that the positions of the sublayers immediately move to their new position.
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
        // Create the region of interest outline
        let width = regionOfInterestWidthScale * bounds.width
        let height = regionOfInterestHeightScale * bounds.height
        let regionX = (bounds.width - width) / 2.0
        let regionY = (bounds.height - height) / 2.0
        regionOfInterest = CGRect(x: regionX, y: regionY, width: width, height: height)
        
        let outlinePath = UIBezierPath(roundedRect: regionOfInterest, cornerRadius: regionOfInterestCornerRadius)
        regionOfInterestOutline.path = outlinePath.cgPath

		// Create the path for the mask layer. We use the even odd fill rule so that the region of interest does not have a fill color.
		let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        path.append(outlinePath)
		path.usesEvenOddFillRule = true
		maskLayer.path = path.cgPath
				
		CATransaction.commit()
	}

}
