//
//  NewsFeedRefreshViewController.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation
import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, NewsFeedLoadingView {
    
    private(set) lazy var view = loadView()
    private let delegate: FeedRefreshViewControllerDelegate
    
    public init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: NewsFeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    func loadView() -> UIRefreshControl{
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
