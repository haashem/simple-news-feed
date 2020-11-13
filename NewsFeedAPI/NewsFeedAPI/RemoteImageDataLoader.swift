//
//  RemoteFeedImageDataLoader.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation
import Networking
import NewsFeedFeature

public final class RemoteImageDataLoader: ImageDataLoader {
    public typealias LoadResult = ImageDataLoader.Result

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let client: HTTPClient
    public init(client: HTTPClient) {
        self.client = client
    }
    
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) {
        client.get(from: URLRequest(url: url)) { result in
            DispatchQueue.main.async {
                let loadResult = result.mapError { _ in Error.connectivity }.flatMap { (data, response) -> Result<Data, Swift.Error> in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
                
                completion(loadResult)
            }
        }
    }
}

