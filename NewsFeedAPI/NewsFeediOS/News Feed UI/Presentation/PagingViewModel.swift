//
//  PagingViewModel.swift
//  NewsFeediOS
//
//  Created by Hashem Aboonajmi on 11/12/20.
//

import Foundation


public struct PagingViewModel: Equatable {

  public let isLoading: Bool
  public let pageNumber: Int

  public var nextPage: Int {
    pageNumber + 1
  }
  
  public init(isLoading: Bool, pageNumber: Int) {
    self.isLoading = isLoading
    self.pageNumber = pageNumber
  }
}
