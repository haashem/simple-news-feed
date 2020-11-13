//
//  NewsFeedPresenter.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation
import NewsFeedFeature

struct NewsFeedLoadingViewModel {
    let isLoading: Bool
}

protocol NewsFeedLoadingView {
    func display(_ viewModel: NewsFeedLoadingViewModel)
}

struct NewsFeedViewModel {
    let feed: [NewsItem]
}

protocol FeedView {
    func display(_ viewModel: NewsFeedViewModel)
}

public protocol PagingView {
  func display(_ viewModel: PagingViewModel)
}

final class NewsFeedPresenter {
    
    let feedView: FeedView
    let loadingView: NewsFeedLoadingView
    let pagingView: PagingView
    
    init(feedView: FeedView, loadingView: NewsFeedLoadingView, pagingView: PagingView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.pagingView = pagingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(NewsFeedLoadingViewModel(isLoading: true))
        pagingView.display(PagingViewModel(isLoading: true, pageNumber: 0))
    }
    
    func didFinishLoadingFeed(with feed: NewsFeed) {
        feedView.display(NewsFeedViewModel(feed: feed.items))
        loadingView.display(NewsFeedLoadingViewModel(isLoading: false))
        pagingView.display(PagingViewModel(isLoading: false, pageNumber: feed.page))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(NewsFeedLoadingViewModel(isLoading: false))
        
    }
}
