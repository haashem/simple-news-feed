//
//  NewsFeedTests.swift
//  NewsFeedTests
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import XCTest
import NewsFeedFeature
import NewsFeedAPI

class NewsFeedTests: XCTestCase {

    func test_init_doesntRequestURL() {
        let client = HTTPClientSpy()
        _ = makeSUT()
        
        XCTAssertTrue(client.messages.isEmpty)
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let baseURLstring = "https://example.com/"
        let baseURL = URL(string: baseURLstring)!
        let expectedURL = URL(string: baseURLstring + "?page=0")
        let (sut, client) = makeSUT(baseURL: baseURL)
        
        sut.load(page: 0) {_ in }
        sut.load(page: 0) {_ in }
        
        XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let givenError = NSError(domain: "test", code: 0, userInfo: nil)
        
        expect(sut, toCompleteWithResult:
            failure(.connectivity), when: {
            client.complete(with: givenError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        
        let (sut, client) = makeSUT()
       
        expect(sut, toCompleteWithResult:
                failure(.tooManyRequests), when: {
            let json = makeItemJSON([])
            client.complete(withStatusCode: 429, data: json, at: 0)
        })
        
        expect(sut, toCompleteWithResult:
                failure(.unauthorized), when: {
            let json = makeItemJSON([])
            client.complete(withStatusCode: 401, data: json, at: 1)
        })
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (arg) in
            
            let (index, code) = arg
            expect(sut, toCompleteWithResult:
                failure(.invalidData), when: {
                let json = makeItemJSON([])
                client.complete(withStatusCode: code, data: json, at: index + 2)
            })
        }
    }
    
    func test_load_givenEmptyResponse_callsCompletionWithEmptyList() {
        let (sut, client) = makeSUT()
        let emptyFeed = NewsFeed(items: [], page: 0)
        expect(sut, toCompleteWithResult: .success(emptyFeed), when: {
            let emptyListJSON = makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_when200HTTPResponseWithInvalidData_deliversError() {
        // given
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult:
            failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_whenValidJSONdata_callCompletionWithNewsFeedItems() {
        // given
        let (sut, client) = makeSUT()
        let item1Date = ISO8601DateFormatter().date(from: "2020-10-14T22:08:43+0000")!
        let item1 = makeItem(id: "nyt://article/fbd09d3c-1730-5c67-bebc-353d22ac513f", title: "McCabe", snippet: "At a", date: item1Date, imageUrl: "images/2020/10/22/us/politics/22dc-intel/22dc-intel-articleLarge-v2.jpg", articleUrl: URL(string: "https://www.nytimes.com/2020/10/22/us/politics/russia-election-interference-hacks.html")!)
        
        let item2Date = ISO8601DateFormatter().date(from: "2020-11-11T00:20:12+0000")!
        let item2 = makeItem(id: "nyt://article/fbd09d3c-1730-5c67-bebc-353d22ac513f", title: "McCabe Rejects Republican Accusations of F.B.I. Corruption in Russia Inquiry", snippet: "At a Senate hearing, Republicans sought to rehash unproven allegations that the bureau targeted President Trump for political reasons.", date: item2Date, imageUrl: nil, articleUrl: URL(string: "https://www.nytimes.com/2020/10/22/us/politics/russia-election-interference-hacks.html")!)
        
        let itemsJSON = makeItemJSON([item1.json, item2.json])
        
        expect(sut, toCompleteWithResult: .success(NewsFeed(items: [item1.model, item2.model], page: 0)), when: {
            client.complete(withStatusCode: 200, data: itemsJSON)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTinstanceHasBeenDeallocated() {
        let url = URL(string: "http://example.com")!
        let client = HTTPClientSpy()
        var sut: NYTimesFeedLoader? = NYTimesFeedLoader(url: url, client: client)
        
        // when
        var capturedResults = [NYTimesFeedLoader.Result]()
        
        sut?.load(page: 0) {
            capturedResults.append($0)
        }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: String, title: String, snippet: String, date: Date, imageUrl: String?, articleUrl: URL) -> (model: NewsItem, json: [String: Any]) {
        
        let item = NewsItem(id: id, title: title, snippet: snippet, date: date, imageUrl: imageUrl != nil ? URL(string: "https://nytimes.com/" + imageUrl!) : nil, articleUrl: articleUrl)
        
        let dateFormatter = ISO8601DateFormatter()
        
        let json = [
            "uri": item.id,
            "headline": ["main": item.title],
            "snippet": item.snippet,
            "pub_date": dateFormatter.string(from: date),
            "multimedia": imageUrl != nil ? [["url": imageUrl]] : [],
            "web_url": item.articleUrl.absoluteString
            ].compactMapValues{$0}
        
        return (item, json)
    }
    
    private func makeSUT(baseURL url: URL = URL(string: "https://example.com")!) -> (NYTimesFeedLoader, HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        
        let sut = NYTimesFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func expect(_ sut: NYTimesFeedLoader, toCompleteWithResult expectedResult: NYTimesFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        sut.load(page: 0) { receivedResult in
            
            switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                case let (.failure(receivedError as NYTimesFeedLoader.Error), .failure(expectedError as NYTimesFeedLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private func failure(_ error: NYTimesFeedLoader.Error) -> NYTimesFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json: [String: Any] = [
            "response": ["docs": items, "meta": ["offset": 0]]]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
}
