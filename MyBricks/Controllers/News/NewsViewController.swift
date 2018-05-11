//
//  NewsViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/11/17.
//  Copyright © 2017 Leif Harrison. All rights reserved.
//

import UIKit

import AlamofireRSSParser

class NewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var feed: RSSFeed?
    var feedItems: [RSSItem] = []

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground()

        tableView.register(UINib(nibName: "NewsItemTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsItemTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        SimpleActivityHUD.show(overView: view)
        BricksetServices.shared.getNews(completion: { result in
            SimpleActivityHUD.hide()
            if let value = result.value {
                self.feed = value
                self.feedItems = value.items
            }

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
        let cell: NewsItemTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.titleLabel.text = feedItem.title
        cell.autherAndDateLabel.attributedText = feedItem.authorAndDateAttributedDecription()
        return cell
    }

}

//==============================================================================
// MARK: - UITableViewDelegate
//==============================================================================

extension NewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedItem = feedItems[indexPath.row]
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

    static let templateAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.slateBlue]
    static let authorAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .bold), NSAttributedStringKey.foregroundColor: UIColor.lightNavy]
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
