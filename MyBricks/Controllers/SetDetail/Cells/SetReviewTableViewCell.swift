//
//  SetReviewTableViewCell.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/17/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import Cosmos

class SetReviewTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    let maxTextHeight: CGFloat = 150
    
    let defaultStarSize: Double = 18
    let smallStarSize: Double = 16
    let defaultStarMargin: Double = 2
    let smallStarMargin: Double = 1

    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var overallRatingView: CosmosView!
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var buildingRatingView: CosmosView!
    @IBOutlet weak var partsRatingView: CosmosView!
    @IBOutlet weak var playabilityRatingView: CosmosView!
    @IBOutlet weak var valueRatingView: CosmosView!
    @IBOutlet weak var reviewContainerView: UIView!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var moreContainer: UIView!
    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet var moreSpacingConstraint: NSLayoutConstraint!

    var moreButtonTapped: (() -> Void)?
    
    // -------------------------------------------------------------------------
    // MARK: - Nib Loading
    // -------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
        summaryContainerView.addBorder()
        summaryContainerView.addGradientBackground()
        reviewContainerView.addBorder()
        reviewContainerView.addGradientBackground()

        moreButton.applyRoundedShadowStyle()

        prepareForReuse()
    }

    // -------------------------------------------------------------------------
    // MARK: - Reuse
    // -------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        authorLabel.text = nil
        overallRatingView.rating = 0
        buildingRatingView.rating = 0
        partsRatingView.rating = 0
        playabilityRatingView.rating = 0
        valueRatingView.rating = 0
        reviewTextView.text = nil
        
        moreContainer.isHidden = false
        moreSpacingConstraint.isActive = true
        textHeightConstraint.isActive = true
    }

    // -------------------------------------------------------------------------
    // MARK: - Property Observers
    // -------------------------------------------------------------------------
    
    var useSmallLayout: Bool = false {
        didSet {
            configureRatingsViews()
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Actions
    // -------------------------------------------------------------------------
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        moreButtonTapped?()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Public
    // -------------------------------------------------------------------------

    func populate(with setReview: SetReview) {
        titleLabel.text = setReview.title
        authorLabel.attributedText = setReview.authorAndDateAttributedDecription()
        overallRatingView.rating = Double(setReview.overallRating ?? 0)
        buildingRatingView.rating = Double(setReview.buildingExperience ?? 0)
        partsRatingView.rating = Double(setReview.parts ?? 0)
        playabilityRatingView.rating = Double(setReview.playability ?? 0)
        valueRatingView.rating = Double(setReview.valueForMoney ?? 0)

        if let reviewText = setReview.formattedReview() {
            reviewTextView.attributedText = reviewText
            
            let maxSize = CGSize(width: reviewTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
            let textSize = reviewTextView.sizeThatFits(maxSize)
            let showMore = (textSize.height > maxTextHeight)
            moreContainer.isHidden = !showMore
            moreSpacingConstraint.isActive = showMore
            textHeightConstraint.isActive = showMore
            
            self.selectionStyle = showMore ? .default : .none
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Private
    // -------------------------------------------------------------------------
    
    private func configureRatingsViews() {
        configureRatingsView(ratingView: buildingRatingView)
        configureRatingsView(ratingView: partsRatingView)
        configureRatingsView(ratingView: playabilityRatingView)
        configureRatingsView(ratingView: valueRatingView)
        configureRatingsView(ratingView: overallRatingView)
    }
    
    private func configureRatingsView(ratingView: CosmosView) {
        ratingView.settings.starSize = useSmallLayout ? smallStarSize : defaultStarSize
        ratingView.settings.fillMode = .precise
        ratingView.settings.starMargin = useSmallLayout ? smallStarMargin : defaultStarMargin
        ratingView.settings.updateOnTouch = false
        ratingView.settings.emptyImage = #imageLiteral(resourceName: "ratingStarEmpty")
        ratingView.settings.filledImage = #imageLiteral(resourceName: "ratingStarFilled")
    }
}

// =============================================================================
// MARK: - SetReview extension
// =============================================================================

extension SetReview {

    static let reviewFontSize: CGFloat = 16
    static let defaultTextColor = UIColor(white: 0.1, alpha: 1.0)
    static let authorTextColor = UIColor.blue
    static let templateAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: reviewFontSize),
        NSAttributedString.Key.foregroundColor: defaultTextColor
    ]
    static let authorAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: reviewFontSize, weight: .bold),
        NSAttributedString.Key.foregroundColor: authorTextColor
    ]

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func authorAndDateAttributedDecription() -> NSAttributedString {
        let attributedDescription = NSMutableAttributedString(string: "Written by ", attributes: SetReview.templateAttributes)
        attributedDescription.append(NSAttributedString(string: author ?? "", attributes: SetReview.authorAttributes))
        if let date = datePosted {
            attributedDescription.append(NSAttributedString(string: ", \(SetReview.dateFormatter.string(from: date))", attributes: SetReview.templateAttributes))
        }

        return attributedDescription
    }

    func formattedReview() -> NSAttributedString? {
        if let string = self.review {
            if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType : NSAttributedString.DocumentType.html,
                    .characterEncoding : String.Encoding.utf8.rawValue
                ]

                var formattedReview = NSMutableAttributedString()
                do {
                    formattedReview = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
                }
                catch {
                    return nil
                }

                formattedReview.beginEditing()

                // Change fonts to something a bit more readable
                let fullRange = NSRange(location: 0, length: formattedReview.length)
                formattedReview.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, _) in
                    if let font = value as? UIFont {
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        let fontSize: CGFloat = SetReview.reviewFontSize

                        var font = UIFont.systemFont(ofSize: fontSize)
                        if isBold {
                            font = UIFont.boldSystemFont(ofSize: fontSize)
                        }
                        else if isItalic {
                            font = UIFont.italicSystemFont(ofSize: fontSize)
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
