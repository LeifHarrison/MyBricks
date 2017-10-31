//
//  NewsItemViewController.swift
//  MyBricks
//
//  Created by Leif Harrison on 10/31/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

import AlamofireRSSParser

class NewsItemViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!

    var newsItem : RSSItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let newsItem = self.newsItem {
            contentTextView.attributedText = stringFromHTML(string: newsItem.itemDescription ?? "")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func stringFromHTML(string: String) -> NSAttributedString? {
        do {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            if let d = data {
                let options: [NSAttributedString.DocumentReadingOptionKey:Any] = [.documentType:NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue]
                let str = try NSAttributedString(data: d, options: options, documentAttributes: nil)
                return str
            }
        }
        catch {
        }
        return nil
    }

}
