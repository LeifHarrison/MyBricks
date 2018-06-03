//
//  MyBricksActivityIndicatorView.swift
//  MyBricks
//
//  Created by Leif Harrison on 5/25/18.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

@IBDesignable
class MyBricksActivityIndicatorView: UIView {

    // MARK: - Types

    enum ActivityIndicatorStyle: Int {
        case small = 0
        case large = 1
        case huge = 2
        
        var dimension: CGFloat {
            switch self {
            case .small: return 20
            case .large: return 40
            case .huge: return 60
            }
        }

    }
    
    // MARK: - Constants

    private let animationDuration: TimeInterval = 1.1
    private let fadeOutDuration: TimeInterval = 0.1
    private let fadeInDuration: TimeInterval = 0.2

    // MARK: - Private

    private var topCircleLayer: CAShapeLayer! = nil
    private var leftCircleLayer: CAShapeLayer! = nil
    private var rightCircleLayer: CAShapeLayer! = nil

    private var pathTop: UIBezierPath! = nil
    private var pathTop2: UIBezierPath! = nil
    private var pathLeft: UIBezierPath! = nil
    private var pathLeft2: UIBezierPath! = nil
    private var pathRight: UIBezierPath! = nil
    private var pathRight2: UIBezierPath! = nil

    private var animating: Bool = false

    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------

    init(style: ActivityIndicatorStyle = .large) {
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

    var style: ActivityIndicatorStyle = .large {
        didSet {
            invalidateIntrinsicContentSize()
            if let view = superview {
                view.layoutIfNeeded()
            }
        }
    }

    @IBInspectable var circleRadius: CGFloat = 2.0 {
        didSet {
            updateLayerProperties()
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

        let midX = bounds.midX
        let midY = bounds.midY

        let radius = startRadius()
        let halfRadius = radius / 2

        topCircleLayer.position = CGPoint(x: midX, y: circleRadius)
        leftCircleLayer.position = CGPoint(x: midX - (halfRadius * sqrt(3)), y: midY + halfRadius)
        rightCircleLayer.position = CGPoint(x: midX + (halfRadius * sqrt(3)), y: midY + halfRadius)

        updateAnimationPaths()
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    override var intrinsicContentSize: CGSize {
        return CGSize(width: style.dimension, height: style.dimension)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateLayerProperties()
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
        
        addAnimations(to: topCircleLayer, path1: pathTop, path2: pathTop2)
        addAnimations(to: leftCircleLayer, path1: pathLeft, path2: pathLeft2)
        addAnimations(to: rightCircleLayer, path1: pathRight, path2: pathRight2)

        animating = true
    }

    func stopAnimating() {
        topCircleLayer.removeAllAnimations()
        leftCircleLayer.removeAllAnimations()
        rightCircleLayer.removeAllAnimations()
        animating = false
        isHidden = hidesWhenStopped
    }

    func isAnimating() -> Bool {
        return animating
    }

    // Uncomment to display animation paths for debugging
//    override func drawRect(rect: CGRect) {
//        super.drawRect(rect)
//        pathTop.stroke()
//        pathLeft.stroke()
//        pathRight.stroke()
//    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func startRadius() -> CGFloat {
        let height = bounds.height
        let width = bounds.width

        return min(height, width) / 2
    }

    private func addCircleLayer() -> CAShapeLayer {
        let newLayer = CAShapeLayer()
        newLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        updateLayer(newLayer)
        layer.addSublayer(newLayer)
        return newLayer
    }

    private func setupLayers() {
        clipsToBounds = false
        backgroundColor = UIColor.clear
        
        if topCircleLayer == nil {
            topCircleLayer = addCircleLayer()
        }
        if leftCircleLayer == nil {
            leftCircleLayer = addCircleLayer()
        }
        if rightCircleLayer == nil {
            rightCircleLayer = addCircleLayer()
        }

        updateLayerProperties()
        updateAnimationPaths()
    }

    private func addAnimations(to layer: CALayer, path1: UIBezierPath, path2: UIBezierPath) {
        let moveDuration: TimeInterval = animationDuration - fadeInDuration

        layer.removeAllAnimations()
        
        let fadeInAnim = CABasicAnimation(keyPath: "opacity")
        fadeInAnim.beginTime = moveDuration
        fadeInAnim.duration = fadeInDuration
        fadeInAnim.fromValue = 0.0
        fadeInAnim.toValue = 1.0
        fadeInAnim.isRemovedOnCompletion = false

        let fadeOutAnim = CABasicAnimation(keyPath: "opacity")
        fadeOutAnim.beginTime = moveDuration - fadeOutDuration
        fadeOutAnim.duration = fadeOutDuration
        fadeOutAnim.fromValue = 1.0
        fadeOutAnim.toValue = 0.0

        let moveAnim = CAKeyframeAnimation(keyPath:"position")
        moveAnim.path = path1.cgPath
        moveAnim.beginTime = 0
        moveAnim.duration = moveDuration
        moveAnim.calculationMode = kCAAnimationCubicPaced

        let moveAnim2 = CAKeyframeAnimation(keyPath:"position")
        moveAnim2.path = path2.cgPath
        moveAnim2.beginTime = moveDuration
        moveAnim2.duration = fadeInDuration
        moveAnim2.calculationMode = kCAAnimationCubicPaced

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = MAXFLOAT
        animationGroup.animations = [moveAnim, fadeOutAnim, fadeInAnim, moveAnim2]
        layer.add(animationGroup, forKey:"pathGuide")
    }
    
    private func updateAnimationPaths() {
        let height = bounds.height
        let midX = bounds.midX
        let midY = bounds.midY

        let radius = startRadius()
        let halfRadius = radius / 2
        let quarterRadius = halfRadius / 2
        let top = CGPoint(x: midX, y: circleRadius)
        let left = CGPoint(x: midX - (halfRadius * sqrt(3)), y: midY + halfRadius)
        let right =  CGPoint(x: midX + (halfRadius * sqrt(3)), y: midY + halfRadius)

        let midTop = CGPoint(x: midX, y: halfRadius)
        let midLeft = CGPoint(x: midX - (quarterRadius * sqrt(3)), y: midY + quarterRadius)
        let midRight =  CGPoint(x: midX + (quarterRadius * sqrt(3)), y: midY + quarterRadius)

        pathTop = UIBezierPath()
        pathTop.move(to: top)
        pathTop.addQuadCurve(to: midRight, controlPoint: CGPoint(x: midX + (halfRadius * sqrt(3)), y: midY - halfRadius ))
        pathTop.addLine(to: CGPoint(x: midX, y: midY))
        pathTop2 = UIBezierPath()
        pathTop2.move(to: midTop)
        pathTop2.addLine(to: top)

        pathLeft = UIBezierPath()
        pathLeft.move(to: left)
        pathLeft.addQuadCurve(to: midTop, controlPoint: CGPoint(x: midX - (halfRadius * sqrt(3)), y: midY - halfRadius ))
        pathLeft.addLine(to: CGPoint(x: midX, y: midY))
        pathLeft2 = UIBezierPath()
        pathLeft2.move(to: midLeft)
        pathLeft2.addLine(to: left)

        pathRight = UIBezierPath()
        pathRight.move(to: right)
        pathRight.addQuadCurve(to: midLeft, controlPoint: CGPoint(x: midX, y: height))
        pathRight.addLine(to: CGPoint(x: midX, y: midY))
        pathRight2 = UIBezierPath()
        pathRight2.move(to: midRight)
        pathRight2.addLine(to: right)
    }

    private func updateLayer(_ layer: CAShapeLayer) {
        let diameter = circleRadius * 2
        let rect = CGRect(x: 0, y: 0, width: diameter, height:diameter)
        let path = UIBezierPath(ovalIn: rect)
        layer.bounds = rect
        layer.path = path.cgPath
        layer.fillColor = tintColor.cgColor
    }

    private func updateLayerProperties() {
        if topCircleLayer == nil || leftCircleLayer == nil || rightCircleLayer == nil {
            setupLayers()
            return
        }
        
        updateLayer(topCircleLayer)
        updateLayer(leftCircleLayer)
        updateLayer(rightCircleLayer)
    }

}
