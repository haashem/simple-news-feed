//
//  RemoteFeedItemMapper.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import Foundation

final class FeedItemMapper {
    
    struct Root: Decodable {
        let items: [RemoteFeedItem]
        let page: Int
        
        enum CodingKeys: String, CodingKey {
            case response
        }
        
        enum ResponseCodingKeys: String, CodingKey {
            case docs, meta, offset
        }
        
        enum MetaCodingKeys: String, CodingKey {
            case offset
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let response = try container.nestedContainer(keyedBy: ResponseCodingKeys.self, forKey: .response)
            items = try response.decode([RemoteFeedItem].self, forKey: .docs)
            let meta = try response.nestedContainer(keyedBy: MetaCodingKeys.self, forKey: .meta)
            page = try meta.decode(Int.self, forKey: .offset)/10
        }
    }
    
    enum HTTPCodes: Int {
        case ok = 200
        case unauthorized = 401
        case tooManyRequests = 429
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> Root {
        
        switch response.statusCode {
        case HTTPCodes.unauthorized.rawValue:
            throw NYTimesFeedLoader.Error.unauthorized
        case HTTPCodes.tooManyRequests.rawValue:
            throw NYTimesFeedLoader.Error.tooManyRequests
        case HTTPCodes.ok.rawValue:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let root = try? decoder.decode(Root.self, from: data) else {
                throw NYTimesFeedLoader.Error.invalidData
            }
            return root
        default:
            throw NYTimesFeedLoader.Error.invalidData
        }
    }
}
