//
//  FeedNews.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import Foundation

public struct NewsItem: Equatable {
    public let id: String
    public let title: String
    public let snippet: String
    public let date: Date
    public let imageUrl: URL?
    public let articleUrl: URL
    
    public init(id: String, title: String, snippet: String, date: Date, imageUrl: URL?, articleUrl: URL) {
        self.id = id
        self.title = title
        self.snippet = snippet
        self.date = date
        self.imageUrl = imageUrl
        self.articleUrl = articleUrl
    }
}
