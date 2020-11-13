//
//  NewsFeedViewModel.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation
import NewsFeedFeature


struct NewsItemViewModel<Image> {
    
    let title: String
    let snippet: String
    let image: Image?
    let date: String
    let isLoading: Bool
    let shouldRetry: Bool
}


