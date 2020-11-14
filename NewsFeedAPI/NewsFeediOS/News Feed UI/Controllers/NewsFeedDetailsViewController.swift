//
//  NewsFeedDetailsViewController.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/14/20.
//

import UIKit
import WebKit

public class NewsFeedDetailsViewController: UIViewController, WKNavigationDelegate {
    
    public var webView: WKWebView!
    public let url: URL
    
    public init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
    }
}
