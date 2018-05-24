//
//  NewsItemViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/31/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit
import AlamofireRSSParser

class NewsItemViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var autherAndDateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!

    var newsItem: RSSItem?

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addBorder()
        contentView.addGradientBackground()
        scrollView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let newsItem = self.newsItem {
            titleLabel.text = newsItem.title
            autherAndDateLabel.attributedText = newsItem.authorAndDateAttributedDecription()
            contentTextView.attributedText = newsItem.formattedDescription()
        }
    }

}

//==============================================================================
// MARK: - RSSItem extension
//==============================================================================

// swiftlint:disable unused_closure_parameter

extension RSSItem {

    func formattedDescription() -> NSAttributedString? {
        if let string = self.itemDescription {
            if let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) {
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]

                var formattedDescription = NSMutableAttributedString()
                do {
                    formattedDescription = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
                }
                catch {
                    return nil
                }

                formattedDescription.beginEditing()

                // Center and add some spacing to any attached images
                let fullRange = NSRange(location: 0, length: formattedDescription.length)
                formattedDescription.enumerateAttribute(.attachment, in:fullRange, options: []) { (value, range, stop) in
                    if value != nil {
                        let paragraphStyle = formattedDescription.attribute(.paragraphStyle, at: range.location, longestEffectiveRange: nil, in: range)
                        if let style = paragraphStyle as? NSParagraphStyle, let newStyle = style.mutableCopy() as? NSMutableParagraphStyle {
                            newStyle.alignment = .center
                            newStyle.paragraphSpacing = 15
                            formattedDescription.addAttribute(.paragraphStyle, value: newStyle, range: range)
                        }
                    }
                }

                // Change fonts to something a bit more readable
                formattedDescription.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                    if let font = value as? UIFont {
                        let substring = formattedDescription.attributedSubstring(from: range).string
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)

                        var size: CGFloat = 15
                        if substring.contains("©") || substring.contains("Republication prohibited") {
                            size = 13
                        }

                        var font = UIFont.systemFont(ofSize: size)
                        if isBold {
                            font = UIFont.boldSystemFont(ofSize: size)
                        }
                        else if isItalic {
                            font = UIFont.italicSystemFont(ofSize: size)
                        }
                        formattedDescription.addAttribute(.font, value: font, range: range)
                    }
                }

                formattedDescription.endEditing()

                return formattedDescription
            }
        }
        return nil
    }
}

// swiftlint:enable unused_closure_parameter
