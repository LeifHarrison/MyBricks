//
//  ActivityOverlayView.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/20/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

public class ActivityOverlayView: UIView {

    fileprivate var activityIndicator: ActivityIndicatorView = ActivityIndicatorView()
    fileprivate var textLabel: UILabel = UILabel()
    fileprivate var backgroundView: UIView = UIView()

    static private let shared = ActivityOverlayView()

    // -------------------------------------------------------------------------
    // MARK: - Type Methods
    // -------------------------------------------------------------------------
    
    static func show(overView view: UIView, text: String? = nil, animated: Bool = true) {
        shared.show(overView: view, text: text, animated: animated)
    }
    
    static func hide(animated: Bool = true) {
        shared.hide(animated: animated)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Initialization
    // -------------------------------------------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------

    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------
    
    public func show(overView view: UIView, text: String? = nil, animated: Bool = true) {
        self.frame = view.bounds
        self.setNeedsLayout()
        self.layoutIfNeeded()
        view.addSubview(self)
        activityIndicator.startAnimating()

        backgroundView.isHidden = false
        backgroundView.alpha = 0.1
        backgroundView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        
        let animations = {
            self.backgroundView.alpha = 1.0
            self.backgroundView.transform = CGAffineTransform.identity
        }
        let options: UIView.AnimationOptions = [ .beginFromCurrentState, .curveEaseIn ]
        UIView.animate(withDuration: animated ? 0.2 : 0, delay: 0, options: options, animations: animations, completion: nil)

    }
    
    public func hide(animated: Bool = true) {
        let animations = {
            self.backgroundView.alpha = 0.0
            self.backgroundView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        }
        let completion = { (_: Bool) in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        }
        let options: UIView.AnimationOptions = [ .beginFromCurrentState, .curveEaseOut ]
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: options, animations: animations, completion: completion)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------
    
    private func setup() {
        tintColor = UIColor.lightBlueGrey
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.text = "Loading..."
        textLabel.textColor = tintColor
        textLabel.font = .systemFont(ofSize: UIFont.labelFontSize)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.backgroundColor = UIColor.white
        backgroundView.layer.cornerRadius = 5
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowRadius = 5
        backgroundView.layer.shadowOpacity = 0.7
        backgroundView.layer.shadowOffset =  CGSize(width: 1, height: 1)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(activityIndicator)
        backgroundView.addSubview(textLabel)
        
        activityIndicator.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        textLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 25).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 25).isActive = true
        textLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 15).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20).isActive = true
        
        addSubview(backgroundView)
        backgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
}
