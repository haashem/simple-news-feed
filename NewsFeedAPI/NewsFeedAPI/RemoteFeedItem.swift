//
//  RemoteFeedItem.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: String
    let title: String
    let date: Date
    let snippet: String
    let imageURL: URL?
    let articleURL: URL
    
    enum CodingKeys: String, CodingKey {
        case uri, headline, snippet, date = "pub_date", multimedia, articleURL = "web_url"
    }
    
    enum HeadlineCodingKeys: String, CodingKey {
        case main
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let headlineContainer = try container.nestedContainer(keyedBy: HeadlineCodingKeys.self, forKey: .headline)
        
        id = try container.decode(String.self, forKey: .uri)
        title = try headlineContainer.decode(String.self, forKey: .main)
        date = try container.decode(Date.self, forKey: .date)
        snippet = try container.decode(String.self, forKey: .snippet)
        articleURL = try container.decode(URL.self, forKey: .articleURL)
        if let imageURLstring = (try container.decode([Multimedia].self, forKey: .multimedia)).first?.url {
            imageURL = URL(string: "https://nytimes.com/" + imageURLstring)
        } else {
            imageURL = nil
        }
    }
}



private struct Multimedia: Decodable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url
    }
}


