//
//  SetPartsTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

class SetPartsTableViewCell: UITableViewCell {

    @IBOutlet weak var partsLabel: UILabel!
    @IBOutlet weak var setContentsView: UIView!
    @IBOutlet weak var piecesLabel: UILabel!
    @IBOutlet weak var minifiguresLabel: UILabel!

    //--------------------------------------------------------------------------
    // MARK: - Nib Loading
    //--------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }

    //--------------------------------------------------------------------------
    // MARK: - Reuse
    //--------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        partsLabel.text = "Parts List"
        piecesLabel.text = "N/A"
        minifiguresLabel.text = "N/A"
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithSet(_ set : Set) -> Void {
        partsLabel.text = "Parts List"
        piecesLabel.text = "\(set.pieces ?? 0)"
        minifiguresLabel.text = "\(set.minifigs ?? 0)"
    }

}
