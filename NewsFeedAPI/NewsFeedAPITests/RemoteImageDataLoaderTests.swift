//
//  RemoteFeedImageDataLoaderTests.swift
//  NewsFeedTests
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import XCTest
import NewsFeedFeature
import NewsFeedAPI

class RemoteFeedImageDataLoader: XCTestCase {
    
    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageData_requestDataOnEachCall() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: error)
        })
    }
    
    func test_loadImageData_deliversErrorOnNonSuccessResponse() {
        let (sut, client) = makeSUT()
        let samples = [299, 300, 399, 400, 418, 499, 500]
        let data = sampleData()
        samples.enumerated().forEach { (arg) in
            let (index, code) = arg
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_loadImageData_deliversErrorWithEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = sampleData(isEmpty: true)
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageData_deliversSuccessWithNonEmptyData() {
      let (sut, client) = makeSUT()
      let nonEmptyData = sampleData()
      expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
      })
    }
    
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    func expect(_ sut: RemoteImageDataLoader, toCompleteWith expectedResult: RemoteImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        let imageURL = anyURL()

        sut.loadImageData(from: imageURL){ receivedResult in
            switch (receivedResult, expectedResult) {
              case let (.success(receivedData), .success(expectedData)): XCTAssertEqual(receivedData, expectedData, file: file, line: line)
              case let (.failure(receivedError as RemoteImageDataLoader.Error), .failure(expectedError as RemoteImageDataLoader.Error)): XCTAssertEqual(receivedError, expectedError, file: file, line: line)
              default: XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteImageDataLoader.Error) -> ImageDataLoader.Result {
        return .failure(error)
    }
}
