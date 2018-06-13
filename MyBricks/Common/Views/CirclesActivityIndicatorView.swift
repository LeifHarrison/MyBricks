//
//  CirclesActivityIndicatorView.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/12/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

@IBDesignable
class CirclesActivityIndicatorView: UIView {

    // MARK: - Types
    
    enum ActivityIndicatorStyle: Int {
        case small = 0
        case large = 1
        case huge = 2
        
        var dimension: CGFloat {
            switch self {
            case .small: return 20
            case .large: return 40
            case .huge: return 80
            }
        }
        
    }

    private var animating: Bool = false

    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------
    
    init(style: ActivityIndicatorStyle = .huge) {
        super.init(frame:.zero)
        self.style = style
        setupLayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Properties
    //--------------------------------------------------------------------------
    
    var style: ActivityIndicatorStyle = .huge {
        didSet {
            invalidateIntrinsicContentSize()
            if let view = superview {
                view.layoutIfNeeded()
            }
        }
    }
    
    @IBInspectable var circleRadius: CGFloat = 2.0 {
        didSet {
            //updateLayerProperties()
        }
    }
    
    @IBInspectable var hidesWhenStopped: Bool = true {
        didSet {
            isHidden = hidesWhenStopped && !isAnimating()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Interface Builder
    //--------------------------------------------------------------------------
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayers()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Layout
    //--------------------------------------------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: style.dimension, height: style.dimension)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
    }
    
    func setAnimating(animating: Bool) {
        if animating && !isAnimating() {
            startAnimating()
        }
        else {
            stopAnimating()
        }
    }
    
    func startAnimating() {
        isHidden = false
        animating = true
    }
    
    func stopAnimating() {
        animating = false
        isHidden = hidesWhenStopped
    }
    
    func isAnimating() -> Bool {
        return animating
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    func setupLayers() {
        print("layer.frane = \(layer.frame)")
        //layer.borderColor = UIColor.cloudyBlue.cgColor
        //layer.borderWidth = 2.0
        
        let dotCount = 16
        let size = CGSize(width: style.dimension, height: style.dimension)
        let circleSpacing: CGFloat = -2
        let circleSize = (style.dimension - 4 * circleSpacing) / 7
        //let centerX = (layer.bounds.size.width - style.dimension) / 2
        //let centerY = (layer.bounds.size.height - style.dimension) / 2
        let duration: CFTimeInterval = 0.9
        let beginTime = CACurrentMediaTime()
        
        let interval: CFTimeInterval = duration / Double(dotCount)
        //let beginTimes: [CFTimeInterval] = [0, 0.12, 0.24, 0.36, 0.48, 0.6, 0.72, 0.84]
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        
        scaleAnimation.keyTimes = [0, 1]
        scaleAnimation.values = [1, 0.4]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        
        opacityAnimaton.keyTimes = [0, 1]
        opacityAnimaton.values = [1, 0.3]
        opacityAnimaton.duration = duration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [scaleAnimation, opacityAnimaton]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        for index in 0 ..< dotCount {
            let angle = (CGFloat(Double.pi / Double(dotCount/2)) * CGFloat(index)) - CGFloat(Double.pi / 2)
            let circle = circleAt(angle: angle, diameter: circleSize, origin: CGPoint(x: 0, y: 0), containerSize: size, color: UIColor.lightBlueGrey)
            animation.beginTime = beginTime + (Double(index) * interval)
            circle.add(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
    }
    
    func circleAt(angle: CGFloat, diameter: CGFloat, origin: CGPoint, containerSize: CGSize, color: UIColor) -> CALayer {
        print("angle: \(angle), diameter: \(diameter), origin: \(origin), containerSize: \(containerSize)")
        let radius = (containerSize.width / 2) - (diameter / 2)
        let size = CGSize(width: 11, height: 11)
        
        let dotLayer: CAShapeLayer = CAShapeLayer()
        dotLayer.fillColor = color.cgColor
        dotLayer.backgroundColor = nil

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(ovalIn: rect)
        dotLayer.path = path.cgPath

        let dotX = origin.x + radius * (cos(angle) + 1)
        let dotY = origin.y + radius * (sin(angle) + 1)
        let frame = CGRect( x: dotX, y: dotY, width: size.width, height: size.height)
        dotLayer.frame = frame
        print("dotLayer.frame = \(dotLayer.frame)")

        return dotLayer
    }
}
