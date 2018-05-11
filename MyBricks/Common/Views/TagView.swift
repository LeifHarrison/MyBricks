//
//  TagView.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/9/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

open class TagView: UIView {

    let titleLabel = UILabel()
    
    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    public init(title: String) {
        super.init(frame: CGRect.zero)
        titleLabel.text = title
        commitInit()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Properties
    //--------------------------------------------------------------------------

    open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    open var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    open var borderColor: UIColor? {
        didSet {
            updateColors()
        }
    }
    
    open var textColor: UIColor = UIColor.white {
        didSet {
            updateColors()
        }
    }

    open var titleLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            titleLabel.lineBreakMode = titleLineBreakMode
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    open var paddingY: CGFloat = 2 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    open var paddingX: CGFloat = 5 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    open var tagBackgroundColor: UIColor = UIColor.gray {
        didSet {
            updateColors()
        }
    }
    
    var textFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            titleLabel.font = textFont
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Overrides
    //--------------------------------------------------------------------------
    
    override open var bounds: CGRect {
        didSet {
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Layout
    //--------------------------------------------------------------------------
    
    override open var intrinsicContentSize: CGSize {
        var size = titleLabel.intrinsicContentSize
        size.height += paddingY * 2
        size.width += paddingX * 2
        if size.width < size.height {
            size.width = size.height
        }
        return size
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        var titleFrame = titleLabel.frame
        titleFrame.origin.x = paddingX
        titleFrame.origin.y = paddingY
        titleLabel.frame = titleFrame
        titleLabel.sizeToFit()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func commitInit() {
        titleLabel.lineBreakMode = titleLineBreakMode
        addSubview(titleLabel)
        frame.size = intrinsicContentSize
    }
    
    private func updateColors() {
        backgroundColor = tagBackgroundColor
        layer.borderColor = borderColor?.cgColor
        titleLabel.textColor = textColor
    }
    
}
