//
//  SetReviewTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit
import Cosmos

class SetReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var overallRatingView: CosmosView!
    @IBOutlet weak var buildingRatingView: CosmosView!
    @IBOutlet weak var partsRatingView: CosmosView!
    @IBOutlet weak var playabilityRatingView: CosmosView!
    @IBOutlet weak var valueRatingView: CosmosView!
    @IBOutlet weak var reviewTextView: UITextView!

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
    }

    //--------------------------------------------------------------------------
    // MARK: - Public
    //--------------------------------------------------------------------------

    func populateWithSetReview(review : SetReview) -> Void {
        titleLabel.text = review.title
        authorLabel.attributedText = review.authorAndDateAttributedDecription()
        overallRatingView.rating = Double(review.overallRating ?? 0)
        buildingRatingView.rating = Double(review.buildingExperience ?? 0)
        partsRatingView.rating = Double(review.parts ?? 0)
        playabilityRatingView.rating = Double(review.playability ?? 0)
        valueRatingView.rating = Double(review.valueForMoney ?? 0)
        reviewTextView.attributedText = review.formattedReview()
        print("contentSize: \(reviewTextView.contentSize)")
    }

}

//==============================================================================
// MARK: - SetReview extension
//==============================================================================

extension SetReview {

    static let textColor = UIColor(white:0.1, alpha:1.0)
    static let templateAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: textColor]
    static let authorAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.blue]

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func authorAndDateAttributedDecription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string:"Written by ", attributes:SetReview.templateAttributes)
        attributedDescription.append(NSAttributedString(string:author ?? "", attributes:SetReview.authorAttributes))
        if let date = datePosted {
            attributedDescription.append(NSAttributedString(string:", \(SetReview.dateFormatter.string(from: date))", attributes:SetReview.templateAttributes))
        }

        return attributedDescription
    }

    func formattedReview() -> NSAttributedString? {
        if let string = self.review {
            if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                let options: [NSAttributedString.DocumentReadingOptionKey:Any] = [
                    .documentType:NSAttributedString.DocumentType.html,
                    .characterEncoding:String.Encoding.utf8.rawValue
                ]

                var formattedReview = NSMutableAttributedString()
                do {
                    formattedReview = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
                }
                catch {
                    return nil
                }

                formattedReview.beginEditing()

                let fullRange = NSMakeRange(0, formattedReview.length)

//                // Center and add some spacing to any attached images
//                formattedReview.enumerateAttribute(NSAttributedStringKey.attachment, in:fullRange, options: []) { (value, range, stop) in
//                    if (value != nil) {
//                        let paragraphStyle = formattedReview.attribute(.paragraphStyle, at: range.location, longestEffectiveRange: nil, in: range)
//                        print("paragraphStyle: \(String(describing: paragraphStyle))")
//                        if let style = paragraphStyle as? NSParagraphStyle {
//                            let newStyle = style.mutableCopy() as! NSMutableParagraphStyle
//                            newStyle.alignment = .center
//                            newStyle.paragraphSpacing = 15
//                            formattedReview.addAttribute(.paragraphStyle, value: newStyle, range: range)
//                        }
//                    }
//                }
//
                // Change fonts to something a bit more readable
                formattedReview.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                    if let font = value as? UIFont {
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)

                        let size: CGFloat = 14

                        var font = UIFont.systemFont(ofSize: size)
                        if isBold {
                            font = UIFont.boldSystemFont(ofSize: size)
                        }
                        else if isItalic {
                            font = UIFont.italicSystemFont(ofSize: size)
                        }
                        formattedReview.addAttribute(.font, value: font, range: range)
                    }
                }

                formattedReview.endEditing()

                return formattedReview
            }
        }
        return nil
    }
}

