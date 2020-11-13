//
//  NewsFeed.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/13/20.
//

import Foundation

public struct NewsFeed: Equatable {
    public let items: [NewsItem]
    public let page: Int
    
    public init(items: [NewsItem], page: Int) {
        self.items = items
        self.page = page
    }
}
