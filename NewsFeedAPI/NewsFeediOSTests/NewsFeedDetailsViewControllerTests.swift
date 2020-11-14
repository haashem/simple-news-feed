//
//  NewsFeedDetailsViewControllerTests.swift
//  NewsFeediOSTests
//
//  Created by Hashem Aboonajmi on 11/14/20.
//

import XCTest
import NewsFeediOS
import WebKit

class NewsFeedDetailsViewControllerTests: XCTestCase {

    func test_init_articleUrlIsSet() {
        let sut = NewsFeedDetailsViewController(url: anyURL())
        XCTAssertNotNil(sut.url)
    }
    
    func test_viewIsWebView() {
        let sut = NewsFeedDetailsViewController(url: anyURL())
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.view.isKind(of: WKWebView.self))
    }
    
    func test_viewDidLoad_loadsWebUrl() {
        let sut = NewsFeedDetailsViewController(url: anyURL())
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.webView.isLoading)
    }
    
    

}
