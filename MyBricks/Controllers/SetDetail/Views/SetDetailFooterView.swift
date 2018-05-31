//
//  SetDetailFooterView.swift
//  MyBricks
//
//  Created by Leif Harrison on 2/6/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailFooterView: UIView {

    @IBOutlet weak var openOnBricksetButton: UIButton!
    @IBOutlet weak var dateLastUpdatedLabel: UILabel!

    static let dateFormatter = DateFormatter()

    var bricksetURL: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        SetDetailFooterView.dateFormatter.dateStyle = .medium
        SetDetailFooterView.dateFormatter.timeStyle = .medium

        addBorder()
        addGradientBackground(withColors: [UIColor.almostWhite, UIColor.paleGrey])
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func openOnBricksetButtonTapped(_ sender: UIButton) {
        if let url = bricksetURL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populateWithSet(_ set: Set) {
        if let dateLastUpdated = set.lastUpdated {
            dateLastUpdatedLabel.text = "Last Updated " + SetDetailFooterView.dateFormatter.string(from: dateLastUpdated)
        }
        if let bricksetURLString = set.bricksetURL {
            bricksetURL = URL(string: bricksetURLString)
        }
    }

}
