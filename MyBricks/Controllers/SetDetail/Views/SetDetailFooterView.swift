//
//  SetDetailFooterView.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 2/6/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class SetDetailFooterView: UIView {

    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var openOnBricksetButton: UIButton!
    @IBOutlet weak var dateLastUpdatedLabel: UILabel!

    static let dateFormatter = DateFormatter()

    var bricksetURL: URL? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        SetDetailFooterView.dateFormatter.dateStyle = .long
        SetDetailFooterView.dateFormatter.timeStyle = .medium

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
    
    func populateWithSet(_ set : Set) -> Void {
        if let dateLastUpdated = set.lastUpdated {
            dateLastUpdatedLabel.text = "Last Updated " + SetDetailFooterView.dateFormatter.string(from: dateLastUpdated)
        }
        if let bricksetURLString = set.bricksetURL {
            bricksetURL = URL(string: bricksetURLString)
        }
    }

}
