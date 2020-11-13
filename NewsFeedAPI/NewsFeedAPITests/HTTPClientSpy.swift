//
//  HTTPClientSpy.swift
//  NewsFeedTests
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation
import Networking

class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from requets: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((requets.url!, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
