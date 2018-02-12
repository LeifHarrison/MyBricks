//
//  SetTagsTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/9/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

@IBDesignable
open class TagListView: UIView {
    
    //--------------------------------------------------------------------------
    // MARK: - IBInspectable Properties
    //--------------------------------------------------------------------------
    
    @IBInspectable open dynamic var textFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            tagViews.forEach( { $0.textFont = textFont } )
            setNeedsLayout()
        }
    }
    
    @IBInspectable open dynamic var textColor: UIColor = UIColor.white {
        didSet {
            tagViews.forEach( { $0.textColor = textColor } )
        }
    }
    
    @IBInspectable open dynamic var tagLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            tagViews.forEach( { $0.titleLineBreakMode = tagLineBreakMode } )
        }
    }
    
    @IBInspectable open dynamic var tagBackgroundColor: UIColor = UIColor.gray {
        didSet {
            tagViews.forEach( { $0.tagBackgroundColor = tagBackgroundColor } )
        }
    }
    
    @IBInspectable open dynamic var borderWidth: CGFloat = 0 {
        didSet {
            tagViews.forEach( { $0.borderWidth = borderWidth } )
        }
    }
    
    @IBInspectable open dynamic var borderColor: UIColor? {
        didSet {
            tagViews.forEach( { $0.borderColor = borderColor } )
        }
    }
    
    @IBInspectable open dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            tagViews.forEach( { $0.cornerRadius = cornerRadius } )
        }
    }
    
    @IBInspectable open dynamic var paddingY: CGFloat = 2 {
        didSet {
            tagViews.forEach( { $0.paddingY = paddingY } )
            setNeedsLayout()
        }
    }
    
    @IBInspectable open dynamic var paddingX: CGFloat = 5 {
        didSet {
            tagViews.forEach( { $0.paddingX = paddingX } )
            setNeedsLayout()
        }
    }
    
    @IBInspectable open dynamic var marginY: CGFloat = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open dynamic var marginX: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open dynamic var shadowColor: UIColor = UIColor.white {
        didSet {
            tagViews.forEach( { $0.layer.shadowColor = shadowColor.cgColor } )
        }
    }
    
    @IBInspectable open dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            tagViews.forEach( { $0.layer.shadowRadius = shadowRadius } )
        }
    }
    
    @IBInspectable open dynamic var shadowOffset: CGSize = CGSize.zero {
        didSet {
            tagViews.forEach( { $0.layer.shadowOffset = shadowOffset } )
        }
    }
    
    @IBInspectable open dynamic var shadowOpacity: Float = 0 {
        didSet {
            tagViews.forEach( { $0.layer.shadowOpacity = shadowOpacity } )
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Properties
    //--------------------------------------------------------------------------

    open private(set) var tagViews: [TagView] = []

    //--------------------------------------------------------------------------
    // MARK: - Interface Builder
    //--------------------------------------------------------------------------

    open override func prepareForInterfaceBuilder() {
        addTag("Welcome")
        addTag("to")
        addTag("TagListView")
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Layout
    //--------------------------------------------------------------------------

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for tagView in tagViews {
            tagView.frame.size = tagView.intrinsicContentSize
            if currentRowWidth + tagView.frame.width > frame.width {
                currentRowWidth = 0
                tagView.frame.size.width = min(tagView.frame.width, frame.width)
                currentRowHeight += tagView.frame.height + marginY
            }
            tagView.frame.origin = CGPoint(x: currentRowWidth, y: currentRowHeight)
            currentRowWidth += tagView.frame.width + marginX
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        var rowCount = (tagViews.count > 0) ? 1 : 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var tagViewHeight: CGFloat = 0

        for tagView in tagViews {
            let tagViewSize = tagView.intrinsicContentSize
            if tagViewHeight < tagViewSize.height { tagViewHeight = tagViewSize.height }
            
            if currentRowWidth + tagViewSize.width > frame.width {
                rowCount += 1
                currentRowWidth = 0
                currentRowHeight += tagViewSize.height + marginY
            }
            
            currentRowWidth += tagViewSize.width + marginX
        }

        var height = CGFloat(rowCount) * (tagViewHeight + marginY)
        if rowCount > 0 {
            height -= marginY
        }
        return CGSize(width: frame.width, height: height)
    }

    //--------------------------------------------------------------------------
    // MARK: - Manage Tags
    //--------------------------------------------------------------------------
    
    private func createNewTagView(_ title: String) -> TagView {
        let tagView = TagView(title: title)

        tagView.textColor = textColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.titleLineBreakMode = tagLineBreakMode
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        addSubview(tagView)
        
        return tagView
    }

    @discardableResult
    open func addTag(_ title: String) -> TagView {
        return addTagView(createNewTagView(title))
    }
    
    @discardableResult
    open func addTags(_ titles: [String]) -> [TagView] {
        var tagViews: [TagView] = []
        for title in titles {
            tagViews.append(createNewTagView(title))
        }
        return addTagViews(tagViews)
    }
    
    @discardableResult
    open func addTagViews(_ tagViews: [TagView]) -> [TagView] {
        for tagView in tagViews {
            self.tagViews.append(tagView)
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        return tagViews
    }

    @discardableResult
    open func insertTag(_ title: String, at index: Int) -> TagView {
        return insertTagView(createNewTagView(title), at: index)
    }
    
    @discardableResult
    open func addTagView(_ tagView: TagView) -> TagView {
        tagViews.append(tagView)
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        return tagView
    }

    @discardableResult
    open func insertTagView(_ tagView: TagView, at index: Int) -> TagView {
        tagViews.insert(tagView, at: index)
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        return tagView
    }
    
    open func setTitle(_ title: String, at index: Int) {
        tagViews[index].titleLabel.text = title
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    open func removeTag(_ title: String) {
        // loop the array in reversed order to remove items during loop
        for index in stride(from: (tagViews.count - 1), through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.titleLabel.text == title {
                removeTagView(tagView)
            }
        }
    }
    
    open func removeTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.index(of: tagView) {
            tagViews.remove(at: index)
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    open func removeAllTags() {
        for view in tagViews {
            view.removeFromSuperview()
        }
        tagViews = []
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

}
