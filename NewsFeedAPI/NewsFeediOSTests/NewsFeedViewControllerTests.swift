//
//  NewsFeedViewControllerTests.swift
//  NewsFeediOSTests
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import XCTest
import UIKit
import NewsFeedFeature
import NewsFeediOS

class NewsFeedViewControllerTests: XCTestCase {

    func test_init_doesnNotLoadFeed() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
    
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndictor, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndictor, "Expected no loading indicator once loading completes successfully")
    }
    
    func test_viewDidLoad_hideLoadingIndicatorWhenLoadingFailed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWithError (at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndictor, "Expected no loading indicator once user initiated loading is completes with error")
    }
    
    func test_feedLoadCompletion_rendersSuccessfullyLoadedFeed() {
        let item0 = makeItem(id: "0", title: "title0", snippet: "snippet0", date: Date(), imageUrl: URL(string: "https://nytimes.com/image/path0.jpg"), articleUrl: anyURL())
        let item1 = makeItem(id: "1", title: "title1", snippet: "snippet1", date: Date(), imageUrl: URL(string: "https://nytimes.com/image/path1.jpg"), articleUrl: anyURL())
       
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: NewsFeed(items: [item0, item1], page: 0), at: 0)
        assertThat(sut, isRendering: [item0, item1])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let item0 = makeItem(id: "1", title: "title1", snippet: "snippet1", date: Date(), imageUrl: nil, articleUrl: anyURL())
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: NewsFeed(items: [item0], page: 0), at: 0)
        assertThat(sut, isRendering: [item0])
        
        sut.simulateNextRequest()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [item0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let item0 = makeItem(id: "0", title: "title0", snippet: "snippet0", date: Date(), imageUrl: URL(string: "https://nytimes.com/image/path0.jpg"), articleUrl: anyURL())
        let item1 = makeItem(id: "1", title: "title1", snippet: "snippet1", date: Date(), imageUrl: URL(string: "https://nytimes.com/image/path1.jpg"), articleUrl: anyURL())
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: NewsFeed(items: [item0, item1], page: 0), at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until view becomes visible")
        
        sut.simulateNewsItemViewVisisble(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageUrl], "Expected first image URL request once first view becomes visible")
        
        sut.simulateNewsItemViewVisisble(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageUrl, item1.imageUrl], "Expected first image URL request once first view becomes visible")
    }
    
   
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: NewsFeed(items: [makeItem(), makeItem()], page: 0), at: 0)
        
        let view0 = sut.simulateNewsItemViewVisisble(at: 0)
        let view1 = sut.simulateNewsItemViewVisisble(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected no image state change for second view once first image loading completes successfully")
    }
    
    func test_feedImageView_preloadsImageURLwhenNearVisible() {
        let item0 = makeItem(imageUrl: URL(string: "http://url-0.com")!)
        let item1 = makeItem(imageUrl: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: NewsFeed(items: [item0, item1], page: 0), at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image url requests until image is near visible")
        
        sut.simulateNewsItemViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageUrl], "Expected first image url request once first image is near visible")
        
        sut.simulateNewsItemViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageUrl, item1.imageUrl], "Expected second image url request once second image is near visible")
    }
    
    // MAKR: - Helper
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsFeedViewController, loader: LoaderSpy){
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: NewsFeedViewController, isRendering feed: [NewsItem], file: StaticString = #file, line: UInt = #line) {
        
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) news item, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index)
        }
    }
    
    private func assertThat(_ sut: NewsFeedViewController, hasViewConfiguredFor item: NewsItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.newsItemView(at: index)
        
        guard let cell = view as? NewsFeedCell else {
            return XCTFail("Expected \(NewsFeedCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, item.title, "Expected title text to be \(String(describing: item.title)) for news cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, item.snippet, "Expected description text to be \(String(describing: item.snippet)) for news cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.dateText, item.date.toString(), "Expected date text to be \(String(describing: item.date)) for news cell at index \(index)", file: file, line: line)
    }
    
    private func makeItem(id: String = "0", title: String = "title", snippet: String = "snippet", date: Date = Date(), imageUrl: URL? = anyURL(), articleUrl: URL = anyURL()) -> NewsItem {
        
        return NewsItem(id: id, title: title, snippet: snippet, date: date, imageUrl: imageUrl, articleUrl: articleUrl)
    }
    
    class LoaderSpy: NewsFeedLoader, ImageDataLoader {

        // MARK: - FeedLoader
        
        private var feedRequests = [(NewsFeedLoader.Result) -> Void]()
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(page: Int, completion: @escaping (NewsFeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: NewsFeed = NewsFeed(items: [], page: 0), at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private var imageRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map{ $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) {
            imageRequests.append((url, completion))
            
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }

}


private extension NewsFeedViewController {
    
    func simulateUserInitiatedNewsFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateNewsItemViewVisisble(at index: Int) -> NewsFeedCell? {
        return newsItemView(at: index) as? NewsFeedCell
    }
    
    func simulateNewsItemViewNotVisisble(at row: Int) {
        let view = simulateNewsItemViewVisisble(at: row)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }
    
    func simulateNewsItemViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateNewsItemViewNotNearVisible(at row: Int) {
        simulateNewsItemViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func simulateNextRequest() {
      let scrollView = DraggingScrollView()
      scrollView.contentOffset.y = 1000
      scrollViewDidScroll(scrollView)
    }
    
    var isShowingLoadingIndictor: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func newsItemView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection: Int {
        return 0
    }
}

private class DraggingScrollView: UIScrollView {
    override var isDragging: Bool {
        true
    }
}

private extension NewsFeedCell {
    
    var renderedImage: Data? {
        return coverImageView.image?.pngData()
    }
    
    var titleText: String {
        return titleLabel.text!
    }
    
    var descriptionText: String {
        return descriptionLabel.text!
    }
    
    var dateText: String {
        return dateLabel.text!
    }
}


private extension UIRefreshControl {

    func simulatePullToRefresh() {
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

private extension Date {
    
    func toString(format: String = "MMM dd, yyyy") -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.dateFormat = format
            return formatter.string(from: self)
    }
}
