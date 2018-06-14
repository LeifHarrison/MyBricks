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

    private let newsLastUpdatedKey = "newsLastUpdated"
    private let updateInterval: TimeInterval = 5 * 60 // Only refresh every 5 minutes

    private var refreshControl: UIRefreshControl = UIRefreshControl()
    private var refreshActivityIndicator: ActivityIndicatorView = ActivityIndicatorView(style: .small)

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let lastUpdated = UserDefaults.standard.value(forKey: newsLastUpdatedKey) as? Date ?? Date.distantPast
        if feed == nil || Date().timeIntervalSince(lastUpdated) > updateInterval {
            fetchNews()
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------
    
    @IBAction func refreshNews(_ sender: Any) {
        fetchNews()
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------
    
    fileprivate func setupTableView() {
        tableView.register(NewsItemTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        refreshControl.addTarget(self, action: #selector(refreshNews(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.clear
        refreshControl.backgroundColor = UIColor.white
        tableView.addSubview(refreshControl)
        
        refreshActivityIndicator.hidesWhenStopped = false
        refreshActivityIndicator.tintColor = UIColor.lightBlueGrey
        refreshActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addSubview(refreshActivityIndicator)
        refreshActivityIndicator.centerXAnchor.constraint(equalTo: refreshControl.centerXAnchor).isActive = true
        refreshActivityIndicator.centerYAnchor.constraint(equalTo: refreshControl.centerYAnchor).isActive = true
    }
    
    private func fetchNews() {
        if refreshControl.isRefreshing {
            refreshActivityIndicator.startAnimating()
        }
        else {
            ActivityOverlayView.show(overView: view)
        }
        BricksetServices.shared.getNews(completion: { result in
            if self.refreshControl.isRefreshing {
                self.refreshActivityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
            else {
                ActivityOverlayView.hide()
            }
            if let value = result.value {
                UserDefaults.standard.set(Date(), forKey: self.newsLastUpdatedKey)
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
        cell.populate(with: feedItem)
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
