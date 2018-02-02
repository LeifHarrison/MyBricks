//
//  SetImageTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

class SetImageTableViewCell: UITableViewCell {

    @IBOutlet weak var numberBackgroundView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var yearBackgroundView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var setImageView: UIImageView!
    @IBOutlet weak var zoomButton: UIButton!

    var zoomButtonTapped : (() -> Void)? = nil
    var tapGesture: UIGestureRecognizer? = nil
    
    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        numberBackgroundView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        numberBackgroundView.layer.borderWidth = 1.0
        numberBackgroundView.layer.cornerRadius = yearBackgroundView.bounds.height / 2
        
        yearBackgroundView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        yearBackgroundView.layer.borderWidth = 1.0
        yearBackgroundView.layer.cornerRadius = yearBackgroundView.bounds.height / 2

        setImageView.contentMode = .scaleAspectFit
        
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        
        numberLabel.text = ""
        yearLabel.text = ""
        setImageView.image = nil
        
        if let gesture = tapGesture {
            setImageView.removeGestureRecognizer(gesture)
            self.setImageView.isUserInteractionEnabled = false
            tapGesture = nil
        }
        
        zoomButton.isHidden = true
        zoomButtonTapped = nil
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func zoomButtonTapped(_ sender: UIButton) {
        zoomButtonTapped?()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithSet(_ set : Set) -> Void {
        numberLabel.text = set.fullSetNumber
        yearLabel.text = set.year
    }

    func showZoomButton(animated: Bool) {
        zoomButton.alpha = 0.0
        zoomButton.isHidden = false
        let animations = { () -> Void in
            self.zoomButton.alpha = 1.0
        }
        let completion: ((Bool) -> Void) = { finished in
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.zoomButtonTapped(_:)))
            gesture.cancelsTouchesInView = false
            self.setImageView.addGestureRecognizer(gesture)
            self.setImageView.isUserInteractionEnabled = true
            self.tapGesture = gesture
        }
        UIView.animate(withDuration: animated ? 0.25 : 0.0, animations:animations, completion: completion)
    }

}
