//
//  GradientView.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/9/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {

    @IBInspectable var startColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endColor: UIColor = UIColor(white: 0.95, alpha: 1.0) {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.5, y: 0) {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0.5, y: 1) {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 1
    }
}

