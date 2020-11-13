//
//  NewsFeedLoader.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import Foundation

public protocol NewsFeedLoader {
    typealias Result = Swift.Result<NewsFeed, Error>
    func load(page: Int, completion: @escaping(Result) -> Void)
}
