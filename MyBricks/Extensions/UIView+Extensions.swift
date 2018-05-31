//
//  UIView+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/20/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

protocol NibLoadableView: class { }

extension NibLoadableView where Self: UIView {
    
    static var nibName: String {
        // notice the new describing here
        // now only one place to refactor if describing is removed in the future
        return String(describing: self)
    }
    
}

protocol ReusableView: class {}

extension ReusableView where Self: UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}

extension UIView {
    
    func constrainToView(view: UIView) {
        let top = self.topAnchor.constraint(equalTo: view.topAnchor)
        let bottom = view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let leading = self.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing = view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
    }
    
    func constrainToSuperview() {
        if let view = superview {
            self.constrainToView(view: view)
        }
    }
    
    func fadeIn(duration: TimeInterval = 0.3) {
        if isHidden == false, alpha == 1.0 { return }
        
        self.alpha = 0.0
        self.isHidden = false
        
        let animations: (() -> Void) = {
            self.alpha = 1.0
        }
        UIView.animate(withDuration: duration, animations: animations, completion: nil)
    }
    
    func fadeOut(duration: TimeInterval = 0.3) {
        if isHidden { return }

        let animations: (() -> Void) = {
            self.alpha = 0.0
        }
        let completion = { (finished: Bool) -> Void in
            self.isHidden = true
        }
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
    
    func addGradientBackground(withColors colors: [UIColor]? = [UIColor.almostWhite, UIColor.whiteTwo]) {
        let gradientView = GradientView(frame: self.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.startColor = colors?[0] ?? UIColor.almostWhite
        gradientView.endColor = colors?[1] ?? UIColor.whiteTwo
        insertSubview(gradientView, at: 0)
        gradientView.constrainToSuperview()
    }

    func addBorder(withColor color: UIColor = UIColor.whiteThree) {
        layer.borderColor = color.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 2
        layer.masksToBounds = true
    }
    
    func applyBorderShadowStyle() {
        layer.borderColor = UIColor.whiteThree.cgColor
        layer.borderWidth = 1.0 / UIScreen.main.scale
        layer.cornerRadius = 3
        layer.shadowColor = UIColor.blueGrey.cgColor
        layer.shadowOffset =  CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2
    }
    
    func applyRoundedShadowStyle() {
        layer.cornerRadius = self.frame.height / 2
        layer.shadowColor = UIColor.blueGrey.cgColor
        layer.shadowOffset =  CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 2
    }
    
    func applyLightBlackShadowStyle() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset =  CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2
    }
}
