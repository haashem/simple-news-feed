//
//  NYTimesFeedLoader.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import Foundation
import Networking
import NewsFeedFeature

public final class NYTimesFeedLoader: NewsFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case unauthorized
        case tooManyRequests
    }
    
    public typealias Result = NewsFeedLoader.Result
    
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(page: Int, completion: @escaping (Result) -> Void) {
        
        let request = URLRequest(url: url.appendingQueryParameters(["page": "\(page)"]))
   
        client.get(from: request) { [weak self] result in
            guard self != nil else { return }
            DispatchQueue.main.async {
                switch result {
                    case let .success((data, response)):
                        completion(NYTimesFeedLoader.map(data, from: response))
                    case .failure(_):
                        completion(.failure(Error.connectivity))
                    
                }
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let remoteNews = try FeedItemMapper.map(data, response)
            return .success(NewsFeed(items: remoteNews.items.toModels(), page: remoteNews.page))
        } catch {
            return .failure(error)
        }
    }
}


private extension Array where Element == RemoteFeedItem {
    func toModels() -> [NewsItem] {
        return map{ NewsItem(id: $0.id, title: $0.title, snippet: $0.snippet, date: $0.date, imageUrl: $0.imageURL, articleUrl: $0.articleURL) }
    }
}

private extension URL {
    
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        if var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) {
            urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
                .map { URLQueryItem(name: $0, value: $1) }
            
            return urlComponents.url ?? self
        } else {
            return self
        }
    }
}
