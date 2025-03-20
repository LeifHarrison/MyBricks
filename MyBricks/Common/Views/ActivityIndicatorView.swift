//
//  ActivityIndicatorView.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/12/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

@IBDesignable
class ActivityIndicatorView: UIView {

    // MARK: - Types
    
    enum ActivityIndicatorStyle: Int {
        case small = 0
        case large = 1
        case huge = 2
        
        var dimension: CGFloat {
            switch self {
            case .small: return 30
            case .large: return 50
            case .huge: return 80
            }
        }
        
        var numberOfDots: Int {
            switch self {
            case .small: return 12
            case .large: return 14
            case .huge:  return 16
            }
        }

        var dotSize: CGFloat {
            switch self {
            case .small: return 5
            case .large: return 9
            case .huge:  return 11
            }
        }
    }

    private let minimumScale = 0.4
    private let minimumAlpha = 0.3
    
    private var animating: Bool = false
    private var dots: [CAShapeLayer] = []
    
    // -------------------------------------------------------------------------
    // MARK: - Initialization
    // -------------------------------------------------------------------------
    
    init(style: ActivityIndicatorStyle = .huge) {
        super.init(frame: .zero)
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
    
    // -------------------------------------------------------------------------
    // MARK: - Properties
    // -------------------------------------------------------------------------
    
    var style: ActivityIndicatorStyle = .huge {
        didSet {
            removeLayers()
            setupLayers()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var hidesWhenStopped: Bool = true {
        didSet {
            isHidden = hidesWhenStopped && !isAnimating
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Interface Builder
    // -------------------------------------------------------------------------
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayers()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UIView Overrides
    // -------------------------------------------------------------------------
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: style.dimension, height: style.dimension)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        if let color = tintColor {
            for dot in dots {
                dot.fillColor = color.cgColor
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------
    
    var isAnimating: Bool {
        return animating
    }
    
    func setAnimating(animating: Bool) {
        if animating && !isAnimating {
            startAnimating()
        }
        else {
            stopAnimating()
        }
    }
    
    func startAnimating() {
        isHidden = false
        animating = true
        setupAnimations()
    }
    
    func stopAnimating() {
        removeAnimations()
        animating = false
        isHidden = hidesWhenStopped
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------

    func setupLayers() {
        let size = CGSize(width: style.dimension, height: style.dimension)
        let circleSpacing: CGFloat = -2
        let circleSize = (style.dimension - 4 * circleSpacing) / 7
        
        let scaleInterval = CGFloat(1 - minimumScale) / CGFloat(style.numberOfDots)
        let opacityInterval = Float(1 - minimumAlpha) / Float(style.numberOfDots)
        
        // Draw circles
        for index in 0 ..< style.numberOfDots {
            let angle = (CGFloat(Double.pi / Double(style.numberOfDots/2)) * CGFloat(index)) - CGFloat(Double.pi / 2)
            let circle = circleAt(angle: angle, diameter: circleSize, origin: CGPoint(x: 0, y: 0), containerSize: size)

            let scale = 1.0 - (CGFloat(index) * scaleInterval)
            circle.transform = CATransform3DMakeScale(scale, scale, scale)
            circle.opacity = 1.0 - (Float(index) * opacityInterval)
            
            layer.addSublayer(circle)
            dots.append(circle)
        }
    }
    
    func circleAt(angle: CGFloat, diameter: CGFloat, origin: CGPoint, containerSize: CGSize) -> CAShapeLayer {
        let radius = (containerSize.width / 2) - (diameter / 2)
        let size = CGSize(width: style.dotSize, height: style.dotSize)
        
        let dotLayer: CAShapeLayer = CAShapeLayer()
        dotLayer.fillColor = tintColor.cgColor
        dotLayer.backgroundColor = nil

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(ovalIn: rect)
        dotLayer.path = path.cgPath

        let dotX = origin.x + radius * (cos(angle) + 1)
        let dotY = origin.y + radius * (sin(angle) + 1)
        let frame = CGRect( x: dotX, y: dotY, width: size.width, height: size.height)
        dotLayer.frame = frame

        return dotLayer
    }
    
    private func setupAnimations() {
        let duration: CFTimeInterval = 0.9
        let beginTime = CACurrentMediaTime()
        let interval: CFTimeInterval = duration / Double(style.numberOfDots)
        
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0, 1]
        scaleAnimation.values = [1, minimumScale]
        scaleAnimation.duration = duration
        
        // Opacity animation
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimaton.keyTimes = [0, 1]
        opacityAnimaton.values = [1, minimumAlpha]
        opacityAnimaton.duration = duration
        
        // Animation Group
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimaton]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        if let dots = layer.sublayers {
            for (index, circle) in dots.enumerated() {
                animation.beginTime = beginTime + (Double(index) * interval)
                circle.add(animation, forKey: "animation")
            }
        }
    }
    
    private func removeAnimations() {
        if let dots = layer.sublayers {
            for circle in dots {
                circle.removeAllAnimations()
            }
        }
    }
    
    private func removeLayers() {
        for dot in dots {
            dot.removeFromSuperlayer()
        }
        dots.removeAll(keepingCapacity: true)
    }
    
}
