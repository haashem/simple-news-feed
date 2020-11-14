//
//  FeedUIComposer.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import UIKit
import NewsFeedFeature
import WebKit

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedDetailsWith(url: URL) -> NewsFeedDetailsViewController {
        return NewsFeedDetailsViewController(url: url)
    }
    
    public static func feedComposedWith(feedLoader: NewsFeedLoader, imageLoader: ImageDataLoader, selection: @escaping (NewsItem) -> Void = { _ in }) -> NewsFeedViewController {
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let pagingController = PagingController(delegate: presentationAdapter)
        let feedController = NewsFeedViewController(refreshController: refreshController, pagingController: pagingController)
        presentationAdapter.presenter = NewsFeedPresenter(feedView: FeedViewAdapater(controller: feedController, imageLoader: imageLoader, selection: selection), loadingView: WeakRefVirtualProxy(refreshController), pagingView: WeakRefVirtualProxy(pagingController))
        
        return feedController
    }
    
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: NewsFeedLoadingView where T: NewsFeedLoadingView {
    func display(_ viewModel: NewsFeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: PagingView where T: PagingView {
    func display(_ viewModel: PagingViewModel) {
        object?.display(viewModel)
    }
}


extension WeakRefVirtualProxy: NewsItemView where T: NewsItemView, T.Image == UIImage {
    func display(_ model: NewsItemViewModel<UIImage>) {
        object?.display(model)
    }
}

private final class FeedViewAdapater: FeedView {
    private weak var controller: NewsFeedViewController?
    private let imageLoader: ImageDataLoader
    private let selection: (NewsItem) -> Void
    
    init(controller: NewsFeedViewController, imageLoader: ImageDataLoader, selection: @escaping (NewsItem) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: NewsFeedViewModel) {
        controller?.appened(viewModel.feed.map { model in
            let adapter = NewsItemDataLoaderPresentationAdapter<WeakRefVirtualProxy<NewsFeedCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = NewsFeedCellController(delegate: adapter, onSelection: { [selection] in
                selection(model)
            })
            adapter.presenter = NewsItemPresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        })
    }
}

private final class FeedLoaderPresentationAdapter {

    private let feedLoader: NewsFeedLoader
    var presenter: NewsFeedPresenter?
    
    init(feedLoader: NewsFeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func load(page: Int) {
        presenter?.didStartLoadingFeed()
        feedLoader.load(page: page) { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

extension FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh() {
        load(page: 0)
    }
}

extension FeedLoaderPresentationAdapter: PagingControllerDelegate {
    func didRequestPage(page: Int) {
        load(page: page)
    }
}

private final class NewsItemDataLoaderPresentationAdapter<View: NewsItemView, Image>: NewsFeedCellControllerDelegate where View.Image == Image {
     private let model: NewsItem
     private let imageLoader: ImageDataLoader
     
      var presenter: NewsItemPresenter<View, Image>?

      init(model: NewsItem, imageLoader: ImageDataLoader) {
         self.model = model
         self.imageLoader = imageLoader
     }

      func didRequestImage() {
         presenter?.didStartLoadingImageData(for: model)

          let model = self.model
        guard let imageURL = model.imageUrl else {
            return
        }
        imageLoader.loadImageData(from: imageURL) { [weak self] result in
             switch result {
             case let .success(data):
                 self?.presenter?.didFinishLoadingImageData(with: data, for: model)

              case let .failure(error):
                 self?.presenter?.didFinishLoadingImageData(with: error, for: model)
             }
         }
     }

      func didCancelImageRequest() {
         
     }
 }
