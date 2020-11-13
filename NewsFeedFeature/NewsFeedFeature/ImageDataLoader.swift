//
//  FeedImageDataLoader.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void)
}
