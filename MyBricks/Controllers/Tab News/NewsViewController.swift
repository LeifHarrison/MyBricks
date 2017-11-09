//
//  NewsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

import AlamofireRSSParser

class NewsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var feed: RSSFeed? = nil
    var feedItems: [RSSItem] = []

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "NewsItemTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsItemTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        activityIndicator?.startAnimating()
        BricksetServices.shared.getNews(completion: { result in
            self.activityIndicator?.stopAnimating()
            if let value = result.value {
                self.feed = value
                self.feedItems = value.items
            }

            //print("Result: \(result)")
            self.tableView.reloadData()
        })
    }

}

//==============================================================================
// MARK: - UITableViewDataSource
//==============================================================================

extension NewsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedItem = feedItems[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemTableViewCell", for: indexPath) as? NewsItemTableViewCell
        {
            cell.titleLabel.text = feedItem.title
            cell.autherAndDateLabel.attributedText = feedItem.authorAndDateAttributedDecription()

            return cell
        }
        return UITableViewCell()
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension NewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedItem = feedItems[indexPath.row]
        print("feedItem = \(feedItem)")
        if let feedItemVC = storyboard?.instantiateViewController(withIdentifier: "NewsItemViewController") as? NewsItemViewController {
            feedItemVC.newsItem = feedItem
            show(feedItemVC, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

//==============================================================================
// MARK: - RSSItem extensions
//==============================================================================

extension RSSItem {

    static let textColor = UIColor(white:0.1, alpha:1.0)
    static let templateAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: textColor]
    static let authorAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.blue]
    static let dateFormatter = DateFormatter()

    func authorAndDateAttributedDecription() -> NSAttributedString {
        RSSItem.dateFormatter.dateStyle = .medium
        RSSItem.dateFormatter.timeStyle = .short

        let attributedDescription = NSMutableAttributedString(string:"Posted by ", attributes:RSSItem.templateAttributes)
        attributedDescription.append(NSAttributedString(string:author ?? "", attributes:RSSItem.authorAttributes))
        if let date = pubDate {
            attributedDescription.append(NSAttributedString(string:", \(RSSItem.dateFormatter.string(from: date))", attributes:RSSItem.templateAttributes))
        }

        return attributedDescription
    }

}
