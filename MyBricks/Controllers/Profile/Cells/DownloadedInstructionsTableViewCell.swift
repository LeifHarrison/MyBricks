//
//  DownloadedInstructionsTableViewCell.swift
//  MyBricks
//
//  Created by Harrison, Leif (US - Seattle) on 6/26/18.
//  Copyright © 2018 Leif Harrison. All rights reserved.
//

import UIKit

class DownloadedInstructionsTableViewCell: BorderedGradientTableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var setInfoLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    static let dateFormatter = DateFormatter()
    static let sizeFormatter = ByteCountFormatter()

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
        filenameLabel.text = nil
        setInfoLabel.text = nil
        sizeLabel.text = nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------
    
    func populate(with instructions: DownloadedInstructions) {
        filenameLabel.text = instructions.fileName

        var setInfoText = instructions.setNumber ?? ""
        if setInfoText.count > 0 {
            setInfoText.append(" / ")
        }
        if let setName = instructions.setName {
            setInfoText.append(setName)
        }
        setInfoLabel.text = setInfoText
        
        sizeLabel.text = Formatters.fileSizeFormatter.string(fromByteCount: instructions.fileSize)
    }
    
}
