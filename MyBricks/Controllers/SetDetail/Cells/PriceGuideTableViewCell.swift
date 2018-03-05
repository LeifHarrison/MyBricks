//
//  PriceGuideTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 3/1/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class PriceGuideTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var currentNewContainer: UIView!
    @IBOutlet weak var currentUsedContainer: UIView!
    @IBOutlet weak var last6MonthsNewContainer: UIView!
    @IBOutlet weak var last6MonthsUsedContainer: UIView!

    let containerBackgroundColor = UIColor(white: 0.97, alpha: 1.0)
    let containerBorderColor = UIColor(white: 0.8, alpha: 1.0)
    let containerBorderWidth: CGFloat = 1.0
    let containerCornerRadius: CGFloat = 8.0

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        applyOutlineStyle(to: currentNewContainer)
        applyOutlineStyle(to: currentUsedContainer)
        applyOutlineStyle(to: last6MonthsNewContainer)
        applyOutlineStyle(to: last6MonthsUsedContainer)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func applyOutlineStyle(to view: UIView) {
        view.backgroundColor = containerBackgroundColor
        view.layer.borderColor = containerBorderColor.cgColor
        view.layer.borderWidth = containerBorderWidth
        view.layer.cornerRadius = containerCornerRadius
    }

}
