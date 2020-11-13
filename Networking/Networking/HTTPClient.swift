//
//  HTTPClient.swift
//  NewsFeed
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// Completion handler can be invoked in any threads.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from requets: URLRequest, completion: @escaping (Result) -> Void) 
}
