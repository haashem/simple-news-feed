//
//  SharedTestHelpers.swift
//  NewsFeedTests
//
//  Created by Hashem Aboonajmi on 11/11/20.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain:"any error", code: 0, userInfo: nil)
}

func anyURL() ->URL {
    return URL(string: "https://any-url.com")!
}
