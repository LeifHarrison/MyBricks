//
//  SetHeroImageTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetHeroImageTableViewCell: UITableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var themeView: UIView!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var zoomView: UIView!

    let cornerLabelBackgroundColor = UIColor(white: 0.97, alpha: 1.0)
    let cornerLabelBorderColor = UIColor(white: 0.8, alpha: 1.0)
    let cornerLabelBorderWidth: CGFloat = 1.0
    
    var heroImageTapped : (() -> Void)? = nil
    var tapGesture: UIGestureRecognizer? = nil
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //heroImageView.layer.borderColor = cornerLabelBorderColor.cgColor
        //heroImageView.layer.borderWidth = cornerLabelBorderWidth

        applyOutlineStyle(to: numberView)
        applyOutlineStyle(to: yearView)
        applyOutlineStyle(to: ageView)
        applyOutlineStyle(to: themeView)
        applyOutlineStyle(to: zoomView)

        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        
        numberLabel.text = ""
        yearLabel.text = ""
        ageLabel.text = ""
        
        heroImageView.image = nil
        if let gesture = tapGesture {
            heroImageView.removeGestureRecognizer(gesture)
            self.heroImageView.isUserInteractionEnabled = false
            tapGesture = nil
        }
        
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func heroImageTapped(_ sender: UIButton) {
        heroImageTapped?()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithSet(_ set : Set) -> Void {
        numberLabel.text = set.number
        yearLabel.text = set.year
        ageLabel.text = set.ageRangeString
        themeLabel.text = set.theme

        ageView.isHidden = (set.ageMin == nil)
    }

    func showZoomButton(animated: Bool) {
        zoomView.alpha = 0.0
        zoomView.isHidden = false
        let animations = { () -> Void in
            self.zoomView.alpha = 1.0
        }
        let completion: ((Bool) -> Void) = { finished in
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.heroImageTapped(_:)))
            gesture.cancelsTouchesInView = false
            self.heroImageView.addGestureRecognizer(gesture)
            self.heroImageView.isUserInteractionEnabled = true
            self.tapGesture = gesture
        }
        UIView.animate(withDuration: animated ? 0.25 : 0.0, animations:animations, completion: completion)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    private func applyOutlineStyle(to view: UIView) {
        view.backgroundColor = cornerLabelBackgroundColor
        view.layer.borderColor = cornerLabelBorderColor.cgColor
        view.layer.borderWidth = cornerLabelBorderWidth
        view.layer.cornerRadius = view.bounds.height / 2
    }
    
}
