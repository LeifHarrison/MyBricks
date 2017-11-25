//
//  ReviewDetailAnimator.swift
//  MyBricks
//
//  Created by Leif on 11/21/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class ReviewDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    var finalFrame = CGRect.zero

    var dismissCompletion: (()->Void)?
    
    lazy var animatedTextContainer: UIView = {
        let containerView = UIView(frame: originFrame)
        containerView.backgroundColor = UIColor(white:0.95, alpha: 1.0)

        let topSeparator = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: 1))
        topSeparator.autoresizingMask = .flexibleBottomMargin
        topSeparator.backgroundColor = UIColor(white:0.75, alpha: 1.0)
        containerView.addSubview(topSeparator)
        
        let bottomSeparator = UIView(frame: CGRect(x: 0, y: containerView.frame.size.height-1, width: containerView.frame.size.width, height: 1))
        bottomSeparator.autoresizingMask = .flexibleTopMargin
        bottomSeparator.backgroundColor = UIColor(white:0.75, alpha: 1.0)
        containerView.addSubview(bottomSeparator)

        let textView = self.animatedTextView
        var textFrame = containerView.bounds.insetBy(dx: 10, dy: 10)
        textFrame.size.height -= 29 // Space for "more" button and bottom separator
        textView.frame = textFrame
        containerView.addSubview(textView)

        return containerView
    }()
    
    lazy var animatedTextView: UITextView = {
        let textView = UITextView()
        textView.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        textView.backgroundColor = UIColor.clear
        return textView
    }()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromController = transitionContext.viewController(forKey: .from)
        let toController = transitionContext.viewController(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        let detailView = presenting ? toView! : fromView
        let detailController = (presenting ? toController : fromController) as? ReviewDetailViewController

        if #available(iOS 11.0, *) {
            if presenting {
                finalFrame.size.height -= containerView.safeAreaInsets.bottom
            }
        }

        detailView?.alpha = presenting ? 0.0 : 1.0
        animatedTextView.isScrollEnabled = presenting ? false : true

        if let view = toView {
            containerView.addSubview(view)
            containerView.bringSubview(toFront: view)
        }

        self.animatedTextView.attributedText = detailController?.review?.formattedReview()
        self.animatedTextContainer.frame = self.presenting ? self.originFrame : self.finalFrame
        containerView.addSubview(animatedTextContainer)

        detailController?.textView.isHidden = true
        detailController?.closeButton.isHidden = true

        let animations: (() -> Void) = {
            detailView?.alpha = self.presenting ? 1.0 : 0.0
            self.animatedTextContainer.frame = self.presenting ? self.finalFrame : self.originFrame
        }
        let completion: ((Bool) -> Void) = { (Bool) -> Void in
            detailController?.textView.isHidden = false
            detailController?.closeButton.isHidden = false

            self.animatedTextContainer.removeFromSuperview()
            if !self.presenting {
                self.dismissCompletion?()
            }
            transitionContext.completeTransition(true)
        }
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
    
}
