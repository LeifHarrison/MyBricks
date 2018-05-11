//
//  SimpleActivityHUD.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/20/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

public class SimpleActivityHUD: UIView {

    fileprivate var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    fileprivate var textLabel: UILabel = UILabel()
    fileprivate var hudView: UIView = UIView()

    static private let shared = SimpleActivityHUD()

    //--------------------------------------------------------------------------
    // MARK: - Type Methods
    //--------------------------------------------------------------------------
    
    static func show(overView view: UIView, text: String? = nil, animated: Bool = true) {
        shared.show(overView: view, text: text, animated: animated)
    }
    
    static func hide(animated: Bool = true) {
        shared.hide(animated: animated)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    public func show(overView view: UIView, text: String? = nil, animated: Bool = true) {
        self.frame = view.bounds
        self.setNeedsLayout()
        self.layoutIfNeeded()
        view.addSubview(self)
        activityIndicator.startAnimating()

        hudView.isHidden = false
        hudView.alpha = 0.1
        hudView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        
        let animations = {
            self.hudView.alpha = 1.0
            self.hudView.transform = CGAffineTransform.identity
        }
        let options: UIViewAnimationOptions = [ .beginFromCurrentState, .curveEaseIn ]
        UIView.animate(withDuration: animated ? 0.2 : 0, delay: 0, options: options, animations: animations, completion: nil)

    }
    
    public func hide(animated: Bool = true) {
        let animations = {
            self.hudView.alpha = 0.0
            self.hudView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        }
        let completion = { (finished: Bool) -> Void in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        }
        let options: UIViewAnimationOptions = [ .beginFromCurrentState, .curveEaseOut ]
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: options, animations: animations, completion: completion)
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func setup() {
        backgroundColor =  UIColor.black.withAlphaComponent(0.4)
        tintColor = UIColor.darkGray
        
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = tintColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.text = "Loading..."
        textLabel.textColor = tintColor
        textLabel.font = .systemFont(ofSize: UIFont.labelFontSize)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hudView.backgroundColor = UIColor(white: 0.95, alpha: 0.8)
        hudView.layer.cornerRadius = 5
        hudView.layer.shadowColor = UIColor.black.cgColor
        hudView.layer.shadowRadius = 5
        hudView.layer.shadowOpacity = 0.7
        hudView.layer.shadowOffset =  CGSize(width: 1, height: 1)
        hudView.translatesAutoresizingMaskIntoConstraints = false
        
        hudView.addSubview(activityIndicator)
        hudView.addSubview(textLabel)
        
        activityIndicator.topAnchor.constraint(equalTo: hudView.topAnchor, constant: 20).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: hudView.centerXAnchor).isActive = true
        
        textLabel.leadingAnchor.constraint(equalTo: hudView.leadingAnchor, constant: 25).isActive = true
        hudView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 25).isActive = true
        textLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 15).isActive = true
        hudView.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20).isActive = true
        
        addSubview(hudView)
        hudView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
}
